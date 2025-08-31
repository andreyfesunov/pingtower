defmodule PingWorkers.Infrastructure.Repositories.WorkerRepository do
  @moduledoc """
  Repository for workers using MongoDB.
  """

  alias PingWorkers.Domain.Enums.PeriodType
  alias PingWorkers.Domain.Models.{Pagination, Worker}
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

  @doc """
  Gets paged workers with pagination.
  """
  @spec query(pos_integer(), pos_integer()) ::
          {:ok, Pagination.t(Worker.t())} | {:error, String.t()}
  def query(page, page_size) do
    case MongodbFacade.get_database() do
      {:ok, connection, _database} ->
        offset = (page - 1) * page_size
        total = get_total_count(connection)

        with {:ok, docs} <- get_paginated_workers(connection, offset, page_size),
             {:ok, workers} <- parse_workers(docs) do
          {:ok, Pagination.new(workers, page, page_size, total)}
        else
          {:error, reason} ->
            {:error, "Failed to query or parse workers: #{inspect(reason)}"}
        end

      {:error, reason} ->
        {:error, "Failed to get database connection: #{inspect(reason)}"}
    end
  end

  @doc """
  Gets total count of workers.
  """
  @spec count() :: {:ok, non_neg_integer()} | {:error, String.t()}
  def count do
    case MongodbFacade.get_database() do
      {:ok, connection, _database} ->
        total = get_total_count(connection)
        {:ok, total}

      {:error, reason} ->
        {:error, "Failed to get database connection: #{inspect(reason)}"}
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

  defp get_total_count(connection) do
    case Mongo.count_documents(connection, "workers", %{}) do
      {:ok, count} -> count
      {:error, _} -> 0
    end
  end

  defp get_paginated_workers(connection, offset, limit) do
    options = [
      skip: offset,
      limit: limit,
      sort: %{"created_at" => -1}
    ]

    case Mongo.find(connection, "workers", %{}, options) do
      {:error, reason} ->
        {:error, reason}

      %Mongo.Stream{docs: docs} ->
        {:ok, docs}
    end
  end

  defp parse_workers(docs) do
    workers =
      Enum.reduce_while(docs, [], fn doc, acc ->
        case parse_worker(doc) do
          {:ok, worker} -> {:cont, [worker | acc]}
          {:error, _} -> {:halt, {:error, "Failed to parse worker document"}}
        end
      end)

    case workers do
      {:error, reason} -> {:error, reason}
      workers -> {:ok, Enum.reverse(workers)}
    end
  end
end
