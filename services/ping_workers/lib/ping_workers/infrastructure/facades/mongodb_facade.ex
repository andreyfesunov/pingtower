defmodule PingWorkers.Infrastructure.Facades.MongodbFacade do
  @moduledoc """
  Facade for MongoDB operations.

  Manages connection, database setup, and provides a clean interface
  for MongoDB operations.
  """

  use GenServer
  require Logger

  @type t :: %__MODULE__{
          connection: pid(),
          database: String.t(),
          config: map()
        }

  defstruct [:connection, :database, :config]

  @doc """
  Starts the MongoDB facade.
  """
  @spec start_link(list()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Gets the database connection.
  """
  @spec get_database() :: {:ok, pid(), String.t()} | {:error, String.t()}
  def get_database do
    GenServer.call(__MODULE__, :get_database)
  end

  @doc """
  Gets the connection.
  """
  @spec get_connection() :: {:ok, pid()} | {:error, String.t()}
  def get_connection do
    GenServer.call(__MODULE__, :get_connection)
  end

  @doc """
  Ensures the database exists.
  """
  @spec ensure_database() :: :ok | {:error, String.t()}
  def ensure_database do
    GenServer.call(__MODULE__, :ensure_database)
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
    config = Application.get_env(:ping_workers, :mongodb)

    case connect_to_mongodb(config) do
      {:ok, connection, database} ->
        state = %__MODULE__{
          connection: connection,
          database: database,
          config: config
        }

        Logger.info("MongoDB facade started successfully")
        {:ok, state}

      {:error, reason} ->
        Logger.error("Failed to start MongoDB facade: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_call(:get_database, _from, state) do
    {:reply, {:ok, state.connection, state.database}, state}
  end

  @impl true
  def handle_call(:get_connection, _from, state) do
    {:reply, {:ok, state.connection}, state}
  end

  @impl true
  def handle_call(:ensure_database, _from, state) do
    # MongoDB creates databases automatically when first document is inserted
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:get_config, _from, state) do
    {:reply, state.config, state}
  end

  defp connect_to_mongodb(config) do
    case create_connection(config) do
      {:ok, connection} -> {:ok, connection, config.database}
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_connection(config) do
    connection_string = build_connection_string(config)

    case Mongo.start_link(url: connection_string) do
      {:ok, connection} -> {:ok, connection}
      {:error, reason} -> {:error, "Failed to connect to MongoDB: #{inspect(reason)}"}
    end
  end

  defp build_connection_string(config) do
    protocol = if config.ssl, do: "mongodb+srv", else: "mongodb"

    auth =
      if config.username && config.password do
        "#{config.username}:#{config.password}@"
      else
        ""
      end

    # For MongoDB authentication, we need to specify the auth database as a query parameter
    auth_source =
      if config.username && config.password do
        "?authSource=#{config.auth_database || "admin"}"
      else
        ""
      end

    "#{protocol}://#{auth}#{config.host}:#{config.port}/#{config.database}#{auth_source}"
  end
end
