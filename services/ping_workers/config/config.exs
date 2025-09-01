import Config

config :ping_workers, :mongodb, %{
  host: "localhost",
  port: 27017,
  username: "admin",
  password: "admin",
  database: "ping_workers",
  auth_database: "admin",
  ssl: false,
  timeout: 5000
}

config :ping_workers, :rabbitmq, %{
  host: "localhost",
  port: 5672,
  username: "admin",
  password: "admin",
  vhost: "/",
  ssl: false,
  timeout: 5000
}

config :cors_plug,
  origin: ["http://localhost:3000"],
  max_age: 86400,
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
