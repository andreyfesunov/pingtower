defmodule PingWorkers.Infrastructure.Repositories.WorkerRepository do
  @moduledoc """
  Repository for workers using MongoDB.
  """

  alias PingWorkers.Domain.Enums.PeriodType
  alias PingWorkers.Domain.Models.Worker
  alias PingWorkers.Domain.ValueObjects.Url
  alias PingWorkers.Domain.ValueObjects.Uuid
  alias PingWorkers.Infrastructure.Facades.MongodbFacade

  @doc """
  Creates a worker.
  """
  @spec create(Worker.t()) :: {:ok, Worker.t()} | {:error, String.t()}
  def create(worker) do
    with {:ok, connection, _database} <- MongodbFacade.get_database(),
         {:ok, doc} <- prepare_document(worker) do
      case Mongo.insert_one(connection, "workers", doc) do
        {:ok, _} -> {:ok, worker}
        {:error, reason} -> {:error, "Failed to create worker: #{inspect(reason)}"}
      end
    else
      {:error, reason} -> {:error, "Failed to create worker: #{inspect(reason)}"}
    end
  end

  @doc """
  Checks if worker exists.
  """
  @spec exists(Worker.t()) :: {:ok, boolean()} | {:error, String.t()}
  def exists(worker) do
    case MongodbFacade.get_database() do
      {:ok, connection, _database} ->
        case Mongo.find_one(connection, "workers", %{"url" => to_string(worker.url)}) do
          {:error, reason} -> {:error, "Failed to check worker existence: #{inspect(reason)}"}
          result -> {:ok, result != nil}
        end

      {:error, reason} ->
        {:error, "Failed to check worker existence: #{inspect(reason)}"}
    end
  end

  defp prepare_document(worker) do
    uuid_binary = UUID.string_to_binary!(to_string(worker.id))

    doc = %{
      "_id" => %BSON.Binary{binary: uuid_binary, subtype: :uuid},
      "url" => to_string(worker.url),
      "period" => to_string(worker.period),
      "created_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

    {:ok, doc}
  end

  def parse_worker(doc) do
    with {:ok, uuid} <- extract_uuid_from_doc(doc),
         {:ok, period_raw} when is_binary(period_raw) <- Map.fetch(doc, "period"),
         {:ok, period} <- PeriodType.from_string(period_raw),
         {:ok, url_raw} when is_binary(url_raw) <- Map.fetch(doc, "url"),
         {:ok, url} <- Url.new(url_raw) do
      {:ok, Worker.new(uuid, url, period)}
    else
      {:error, _} -> {:error, "Failed to parse worker"}
    end
  end

  defp extract_uuid_from_doc(doc) do
    case Map.fetch(doc, "_id") do
      {:ok, %BSON.Binary{binary: binary, subtype: :uuid}} ->
        binary |> UUID.binary_to_string!() |> Uuid.from_string()

      _ ->
        {:error, "Invalid UUID format in document"}
    end
  end
end
