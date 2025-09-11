defmodule PingWorkers.Infrastructure.Jobs.PingJob do
  @moduledoc """
  GenServer that pings all workers from WorkerRepository by pagination every minute and saves updated info.
  """

  use GenServer
  require Logger

  alias PingWorkers.Domain.Models.PingData
  alias PingWorkers.Domain.Models.Worker
  alias PingWorkers.Infrastructure.Repositories.PingDataRepository
  alias PingWorkers.Infrastructure.Repositories.WorkerRepository

  @interval_ms 60_000
  @page_size 100

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_ping()
    {:ok, Map.put(state, :ping_in_progress, false)}
  end

  @impl true
  def handle_info(:ping_all_workers, state) do
    if state[:ping_in_progress] do
      Logger.warning(
        "PingJob: attempt to start a new ping while the previous one is still running. Skipping launch."
      )

      schedule_ping()
      {:noreply, state}
    else
      Logger.info("PingJob: starting ping of all workers")

      _ =
        Task.start(fn ->
          ping_all_workers()
          GenServer.cast(__MODULE__, :ping_finished)
        end)

      {:noreply, Map.put(state, :ping_in_progress, true)}
    end
  end

  @impl true
  def handle_cast(:ping_finished, state) do
    Logger.info("PingJob: finished pinging all workers, scheduling next run")
    schedule_ping()
    {:noreply, Map.put(state, :ping_in_progress, false)}
  end

  defp schedule_ping do
    Process.send_after(self(), :ping_all_workers, @interval_ms)
  end

  defp ping_all_workers(page \\ 1) do
    case WorkerRepository.query(page, @page_size) do
      {:ok, pagination} ->
        workers = pagination.items

        Enum.each(workers, fn worker ->
          last_ping_time =
            case PingDataRepository.get_last_ping_time(worker) do
              {:ok, dt} -> dt
              _ -> nil
            end

          now = DateTime.utc_now()
          period_seconds = Worker.period_in_seconds(worker)

          should_ping =
            case last_ping_time do
              nil ->
                true

              last_time ->
                DateTime.diff(now, last_time, :second) >= period_seconds
            end

          if should_ping do
            case ping(worker) do
              {:ok, ping_data} ->
                case PingDataRepository.save(ping_data) do
                  :ok ->
                    :ok

                  {:error, reason} ->
                    Logger.error(
                      "Failed to save ping data for worker #{worker.url}: #{inspect(reason)}"
                    )
                end

              {:error, reason} ->
                Logger.error("Ping error for worker #{worker.url}: #{inspect(reason)}")
            end
          else
            Logger.info("PingJob: skipped ping for worker #{worker.url}: period not elapsed")
          end
        end)

        if length(workers) == @page_size do
          ping_all_workers(page + 1)
        else
          :ok
        end

      {:error, reason} ->
        Logger.error("Failed to fetch workers for ping: #{inspect(reason)}")
        :error
    end
  end

  @doc """
  Pings a single worker.
  """
  @spec ping(Worker.t()) :: {:ok, PingData.t()} | {:error, String.t()}
  def ping(worker) do
    Logger.info("Pinging worker #{worker.url}")

    url = to_string(worker.url)

    start_time = System.monotonic_time(:microsecond)
    request_time = DateTime.utc_now()

    http_opts = [
      timeout: 10_000
    ]

    case :httpc.request(:get, {String.to_charlist(url), []}, http_opts, [{:body_format, :binary}]) do
      {:ok, {{version, status_code, reason_phrase}, headers, body}} ->
        end_time = System.monotonic_time(:microsecond)
        response_time = DateTime.utc_now()
        duration_us = end_time - start_time

        detailed_info =
          PingData.new(
            url,
            request_time,
            response_time,
            duration_us,
            version,
            status_code,
            reason_phrase,
            headers,
            byte_size(body)
          )

        Logger.info("Pinged #{url}: #{inspect(detailed_info)}")

        {:ok, detailed_info}

      {:error, reason} ->
        end_time = System.monotonic_time(:microsecond)
        response_time = DateTime.utc_now()
        duration_us = end_time - start_time

        error_info = %{
          url: url,
          request_time: request_time,
          response_time: response_time,
          duration_microseconds: duration_us,
          error: inspect(reason)
        }

        Logger.error("Failed to ping #{url}: #{inspect(error_info)}")

        {:error, "Error pinging #{url}: #{inspect(reason)}"}
    end
  end
end
