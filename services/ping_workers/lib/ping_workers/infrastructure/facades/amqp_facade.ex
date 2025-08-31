defmodule PingWorkers.Infrastructure.Facades.AmqpFacade do
  @moduledoc """
  Facade for AMQP operations.

  Manages connection, channel setup, and provides a clean interface
  for AMQP operations with RabbitMQ.
  """

  use GenServer
  require Logger

  @type t :: %__MODULE__{
          connection: AMQP.Connection.t(),
          channel: AMQP.Channel.t(),
          config: map()
        }

  defstruct [:connection, :channel, :config]

  @doc """
  Starts the AMQP facade.
  """
  @spec start_link(list()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Gets the channel for publishing messages.
  """
  @spec get_channel() :: {:ok, AMQP.Channel.t()} | {:error, String.t()}
  def get_channel do
    GenServer.call(__MODULE__, :get_channel)
  end

  @doc """
  Gets the connection.
  """
  @spec get_connection() :: {:ok, AMQP.Connection.t()} | {:error, String.t()}
  def get_connection do
    GenServer.call(__MODULE__, :get_connection)
  end

  @doc """
  Ensures the exchange exists.
  """
  @spec ensure_exchange(String.t(), atom()) :: :ok | {:error, String.t()}
  def ensure_exchange(exchange_name, type \\ :topic) do
    GenServer.call(__MODULE__, {:ensure_exchange, exchange_name, type})
  end

  @doc """
  Gets the configuration.
  """
  @spec get_config() :: map()
  def get_config do
    GenServer.call(__MODULE__, :get_config)
  end

  @impl true
  def init(_opts) do
    config = Application.get_env(:ping_workers, :rabbitmq)

    case connect_to_rabbitmq(config) do
      {:ok, connection, channel} ->
        state = %__MODULE__{
          connection: connection,
          channel: channel,
          config: config
        }

        Logger.info("AMQP facade started successfully")
        {:ok, state}

      {:error, reason} ->
        Logger.error("Failed to start AMQP facade: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_call(:get_channel, _from, state) do
    {:reply, {:ok, state.channel}, state}
  end

  @impl true
  def handle_call(:get_connection, _from, state) do
    {:reply, {:ok, state.connection}, state}
  end

  @impl true
  def handle_call({:ensure_exchange, exchange_name, type}, _from, state) do
    case AMQP.Exchange.declare(state.channel, exchange_name, type, durable: true) do
      :ok -> {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call(:get_config, _from, state) do
    {:reply, state.config, state}
  end

  defp connect_to_rabbitmq(config) do
    with {:ok, connection} <- create_connection(config),
         {:ok, channel} <- create_channel(connection) do
      {:ok, connection, channel}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_connection(config) do
    connection_opts = [
      host: config.host,
      port: config.port,
      username: config.username,
      password: config.password,
      virtual_host: config.vhost
    ]

    case AMQP.Connection.open(connection_opts) do
      {:ok, connection} -> {:ok, connection}
      {:error, reason} -> {:error, "Failed to connect to RabbitMQ: #{inspect(reason)}"}
    end
  end

  defp create_channel(connection) do
    case AMQP.Channel.open(connection) do
      {:ok, channel} -> {:ok, channel}
      {:error, reason} -> {:error, "Failed to create channel: #{inspect(reason)}"}
    end
  end
end
