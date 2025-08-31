defmodule PingWorkers.Domain.Events.WorkerCreated do
  @moduledoc """
  Event published when a worker is created.
  """

  alias PingWorkers.Domain.Events.WorkerCreated
  alias PingWorkers.Domain.Models.Worker

  @type t :: %__MODULE__{
          worker_id: String.t(),
          url: String.t(),
          period: String.t(),
          created_at: DateTime.t()
        }

  defstruct [:worker_id, :url, :period, :created_at]

  @spec from_model(Worker.t()) :: t()
  def from_model(worker) do
    WorkerCreated.new(
      to_string(worker.id),
      to_string(worker.url),
      to_string(worker.period)
    )
  end

  @spec new(String.t(), String.t(), String.t()) :: t()
  def new(worker_id, url, period) do
    %__MODULE__{
      worker_id: worker_id,
      url: url,
      period: period,
      created_at: DateTime.utc_now()
    }
  end

  defimpl PingWorkers.Domain.Events.Event, for: __MODULE__ do
    def event_type(_event), do: :worker_created

    def routing_key(_event), do: "worker.created"

    def payload(event) do
      %{
        worker_id: event.worker_id,
        url: event.url,
        period: event.period,
        created_at: event.created_at |> DateTime.to_iso8601()
      }
    end

    def version(_event), do: "1.0"
  end
end
