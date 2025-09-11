defmodule PingWorkers.Domain.Models.Worker do
  @moduledoc """
  Worker model.

  The model contains id, url and period.
  """

  alias PingWorkers.Domain.Enums.PeriodType
  alias PingWorkers.Domain.ValueObjects.Url
  alias PingWorkers.Domain.ValueObjects.Uuid

  defstruct [:id, :url, :period]

  @type t :: %__MODULE__{
          id: Uuid.t(),
          url: Url.t(),
          period: PeriodType.t()
        }

  @spec new(Uuid.t(), Url.t(), PeriodType.t()) :: t()
  def new(id, url, period) do
    %__MODULE__{
      id: id,
      url: url,
      period: period
    }
  end

  @spec new(Url.t(), PeriodType.t()) :: t()
  def new(url, period) do
    %__MODULE__{
      id: Uuid.new(),
      url: url,
      period: period
    }
  end

  @doc """
  Returns the period in seconds.
  """
  @spec period_in_seconds(t()) :: integer()
  def period_in_seconds(worker) do
    PeriodType.period_in_seconds(worker.period)
  end
end
