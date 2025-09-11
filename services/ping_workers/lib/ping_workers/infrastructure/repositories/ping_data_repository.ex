defmodule PingWorkers.Infrastructure.Repositories.PingDataRepository do
  @moduledoc """
  Repository for ping data.
  """

  alias PingWorkers.Domain.Models.PingData
  alias PingWorkers.Domain.Models.Worker
  alias PingWorkers.Infrastructure.Facades.MongodbFacade

  @doc """
  Saves ping data.
  """
  @spec save(PingData.t()) :: :ok | {:error, String.t()}
  def save(ping_data) do
    case MongodbFacade.get_database() do
      {:ok, connection, _database} ->
        case Mongo.insert_one(connection, "ping_data", prepare_document(ping_data)) do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, "Failed to save ping data: #{inspect(reason)}"}
        end

      {:error, reason} ->
        {:error, "Failed to get database: #{inspect(reason)}"}
    end
  end

  @doc """
  Gets the last ping time for a worker.
  """
  @spec get_last_ping_time(Worker.t()) :: {:ok, DateTime.t()} | {:error, String.t()}
  def get_last_ping_time(worker) do
    case MongodbFacade.get_database() do
      {:ok, connection, _database} ->
        case Mongo.find_one(connection, "ping_data", %{url: to_string(worker.url)},
               sort: %{"request_time" => -1}
             ) do
          nil ->
            {:error, "No ping data found for this worker"}

          %{"request_time" => request_time} ->
            case DateTime.from_iso8601(request_time) do
              {:ok, dt, _offset} -> {:ok, dt}
              {:error, reason} -> {:error, "Failed to parse request_time: #{inspect(reason)}"}
            end

          other ->
            {:error, "Unexpected result: #{inspect(other)}"}
        end
    end
  end

  defp prepare_document(ping_data) do
    %{
      "_id" => %BSON.Binary{binary: UUID.string_to_binary!(UUID.uuid4()), subtype: :uuid},
      "url" => to_string(ping_data.url),
      "request_time" => DateTime.to_iso8601(ping_data.request_time),
      "response_time" => DateTime.to_iso8601(ping_data.response_time),
      "duration_microseconds" => ping_data.duration_microseconds,
      "http_version" => to_string(ping_data.http_version),
      "status_code" => ping_data.status_code,
      "reason_phrase" => to_string(ping_data.reason_phrase),
      "headers" =>
        Jason.encode!(
          Enum.map(ping_data.headers, fn {k, v} ->
            %{"key" => List.to_string(k), "value" => List.to_string(v)}
          end)
        ),
      "body_length" => ping_data.body_length
    }
  end
end
