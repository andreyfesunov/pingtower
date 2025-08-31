defmodule PingWorkers.Infrastructure.Messaging.EventPublisher do
  @moduledoc """
  Event Publisher for domain events.

  Publishes domain events to RabbitMQ using AMQP facade.
  Events must implement the Event protocol.
  """

  use GenServer
  require Logger

  alias PingWorkers.Domain.Events.Event
  alias PingWorkers.Infrastructure.Facades.AmqpFacade

  @type t :: %__MODULE__{
          exchange_name: String.t(),
          config: map()
        }

  defstruct [:exchange_name, :config]

  @doc """
  Starts the Event Publisher.
  """
  @spec start_link(list()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Publishes a domain event that implements the Event protocol.
  """
  @spec publish_event(Event.t()) :: :ok | {:error, String.t()}
  def publish_event(event) do
    GenServer.cast(__MODULE__, {:publish_event, event})
  end

  @impl true
  def init(opts) do
    exchange_name = Keyword.get(opts, :exchange_name, "pingtower.events")
    config = Application.get_env(:ping_workers, :rabbitmq, %{})

    case AmqpFacade.ensure_exchange(exchange_name, :topic) do
      :ok ->
        state = %__MODULE__{
          exchange_name: exchange_name,
          config: config
        }

        Logger.info("Event Publisher started successfully with exchange: #{exchange_name}")
        {:ok, state}

      {:error, reason} ->
        Logger.error("Failed to ensure exchange exists: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_cast({:publish_event, event}, state) do
    routing_key = Event.routing_key(event)
    message = build_message(event)

    case publish_to_rabbitmq(state.exchange_name, routing_key, message) do
      :ok ->
        event_type = Event.event_type(event)
        Logger.debug("Published event #{event_type} with routing key #{routing_key}")
        {:noreply, state}

      {:error, reason} ->
        event_type = Event.event_type(event)
        Logger.error("Failed to publish event #{event_type}: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  defp publish_to_rabbitmq(exchange_name, routing_key, message) do
    case AmqpFacade.get_channel() do
      {:ok, channel} ->
        case AMQP.Basic.publish(channel, exchange_name, routing_key, message) do
          :ok -> :ok
          {:error, reason} -> {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_message(event) do
    message = %{
      event_type: Event.event_type(event),
      payload: Event.payload(event),
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      version: Event.version(event)
    }

    case Jason.encode(message) do
      {:ok, json} ->
        json

      {:error, _} ->
        event_type = Event.event_type(event)
        Logger.error("Failed to encode message for event #{event_type}")
        "{}"
    end
  end
end
