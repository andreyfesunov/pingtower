import os
import pika
import json
import requests

from dotenv import load_dotenv

load_dotenv()

RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "localhost")
RABBITMQ_PORT = int(os.getenv("RABBITMQ_PORT", 5672))
RABBITMQ_EXCHANGE = os.getenv("RABBITMQ_EXCHANGE", "pingtower.events")
RABBITMQ_QUEUE = os.getenv("RABBITMQ_QUEUE", "worker.created")
RABBITMQ_ROUTING_KEY = os.getenv("RABBITMQ_ROUTING_KEY", "worker.created")
RABBITMQ_USER = os.getenv("RABBITMQ_USER", "admin")
RABBITMQ_PASSWORD = os.getenv("RABBITMQ_PASSWORD", "admin")
RABBITMQ_VHOST = os.getenv("RABBITMQ_VHOST", "/")

GRAFANA_URL = os.getenv("GRAFANA_URL", "http://localhost:3000/api/dashboards/db")
GRAFANA_API_KEY = os.getenv("GRAFANA_API_KEY", "YOUR_GRAFANA_API_KEY")


def create_grafana_dashboard(worker_data):
    """
    Creates a new dashboard in Grafana for a new worker.
    worker_data: dict with worker data (e.g., {'worker_id': ..., 'name': ...})
    Returns True if the dashboard was created successfully, otherwise False.
    """

    payload = worker_data.get("payload", None)

    if not payload:
        print(f"Worker data is missing payload: {worker_data}")
        return False

    url = payload.get("url", None)

    if not url:
        print(f"Worker data is missing url: {payload}")
        return False

    def aggregate_query(match_filter, project=None, group=None, sort=None, limit=100):
        pipeline = []

        match_stage = {
            "$match": {
                "$expr": {
                    "$and": [
                        {"$gt": ["$request_time", {"$toDate": {"$toLong": "$__from"}}]},
                        {"$lt": ["$request_time", {"$toDate": {"$toLong": "$__to"}}]},
                    ]
                }
            }
        }

        for k, v in match_filter.items():
            if k != "request_time":
                match_stage["$match"][k] = v
        pipeline.append(match_stage)

        if group:
            pipeline.append({"$group": group})
        if project:
            pipeline.append({"$project": project})
        if sort:
            pipeline.append({"$sort": sort})

        pipeline.append({"$limit": limit})

        return {
            "datasource": {"uid": "mongodb"},
            "database": "ping_workers",
            "collection": "ping_data",
            "queryText": json.dumps(pipeline),
            "queryType": "table",
            "refId": "A",
        }

    dashboard = {
        "dashboard": {
            "id": None,
            "uid": f"worker-{str(payload.get('worker_id', 'unknown'))[:18]}",
            "title": f"Worker Monitoring - {url}",
            "tags": ["auto-generated", "worker", "mongodb"],
            "timezone": "browser",
            "schemaVersion": 36,
            "version": 0,
            "panels": [
                {
                    "id": 1,
                    "title": "Response Time (microseconds)",
                    "type": "timeseries",
                    "targets": [
                        aggregate_query(
                            match_filter={"url": {"$eq": url}},
                            group={
                                "_id": {
                                    "interval": {
                                        "$toDate": {
                                            "$subtract": [
                                                {"$toLong": "$request_time"},
                                                {
                                                    "$mod": [
                                                        {"$toLong": "$request_time"},
                                                        60000,
                                                    ]
                                                },
                                            ]
                                        }
                                    }
                                },
                                "avg_duration": {"$avg": "$duration_microseconds"},
                            },
                            project={
                                "interval": "$_id.interval",
                                "avg_duration": 1,
                                "_id": 0,
                            },
                            sort={"interval": 1},
                            limit=100,
                        )
                    ],
                    "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
                    "fieldConfig": {
                        "defaults": {"unit": "µs", "min": 0},
                        "overrides": [],
                    },
                    "options": {},
                },
                {
                    "id": 2,
                    "title": "Status Code",
                    "type": "stat",
                    "targets": [
                        aggregate_query(
                            match_filter={"url": {"$eq": url}},
                            project={"status_code": 1, "request_time": 1},
                            sort={"request_time": -1},
                            limit=1,
                        )
                    ],
                    "gridPos": {"h": 4, "w": 6, "x": 12, "y": 0},
                    "fieldConfig": {
                        "defaults": {
                            "unit": "none",
                            "thresholds": [
                                {
                                    "color": "green",
                                    "value": 200,
                                },
                                {
                                    "color": "blue",
                                    "value": 300,
                                },
                                {
                                    "color": "red",
                                    "value": 400,
                                },
                            ],
                        },
                        "overrides": [],
                    },
                    "options": {},
                },
                {
                    "id": 3,
                    "title": "Body Length",
                    "type": "timeseries",
                    "targets": [
                        aggregate_query(
                            match_filter={"url": {"$eq": url}},
                            group={
                                "_id": {
                                    "interval": {
                                        "$toDate": {
                                            "$subtract": [
                                                {"$toLong": "$request_time"},
                                                {
                                                    "$mod": [
                                                        {"$toLong": "$request_time"},
                                                        60000,
                                                    ]
                                                },
                                            ]
                                        }
                                    }
                                },
                                "avg_body_length": {"$avg": "$body_length"},
                            },
                            project={
                                "interval": "$_id.interval",
                                "avg_body_length": 1,
                                "_id": 0,
                            },
                            sort={"interval": 1},
                            limit=100,
                        )
                    ],
                    "gridPos": {"h": 4, "w": 6, "x": 18, "y": 0},
                    "fieldConfig": {
                        "defaults": {"unit": "bytes", "min": 0},
                        "overrides": [],
                    },
                    "options": {},
                },
            ],
            "time": {"from": "now-1h", "to": "now"},
        },
        "folderId": 0,
        "overwrite": False,
    }

    headers = {
        "Authorization": f"Bearer {GRAFANA_API_KEY}",
        "Content-Type": "application/json",
    }

    response = requests.post(GRAFANA_URL, headers=headers, data=json.dumps(dashboard))
    if response.status_code == 200:
        print(f"Dashboard for worker {url} created successfully.")
        return True
    else:
        print(f"Error creating dashboard: {response.status_code} {response.text}")
        return False


def on_message(ch, method, _, body):
    try:
        message = json.loads(body)
        print(f"Received message: {message}")
        success = create_grafana_dashboard(message)
        if success:
            ch.basic_ack(delivery_tag=method.delivery_tag)
            print("Message acknowledged (dashboard created).")
        else:
            print("Dashboard not created, message will be requeued.")
            # Do not acknowledge the message, it will be requeued
    except Exception as e:
        print(f"Error processing message: {e}")
        # Do not acknowledge the message, it will be requeued


def main():
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(
            host=RABBITMQ_HOST,
            port=RABBITMQ_PORT,
            virtual_host=RABBITMQ_VHOST,
            credentials=pika.PlainCredentials(
                username=RABBITMQ_USER, password=RABBITMQ_PASSWORD
            ),
        )
    )
    channel = connection.channel()

    channel.queue_declare(queue=RABBITMQ_QUEUE, durable=True)
    channel.queue_bind(
        exchange=RABBITMQ_EXCHANGE,
        queue=RABBITMQ_QUEUE,
        routing_key=RABBITMQ_ROUTING_KEY,
    )

    print("Waiting for messages from RabbitMQ...")
    channel.basic_consume(
        queue=RABBITMQ_QUEUE, on_message_callback=on_message, auto_ack=False
    )
    channel.start_consuming()


if __name__ == "__main__":
    main()
