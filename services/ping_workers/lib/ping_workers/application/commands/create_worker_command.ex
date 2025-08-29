defmodule PingWorkers.Application.Commands.CreateWorkerCommand do
  alias PingWorkers.Domain.Enums.PeriodType
  alias PingWorkers.Domain.ValueObjects.Url

  defstruct [:url, :period]

  @type t :: %__MODULE__{
          url: Url.t(),
          period: PeriodType.t()
        }

  @spec new(Url.t(), PeriodType.t()) :: t()
  def new(url, period) do
    %__MODULE__{
      url: url,
      period: period
    }
  end
end
