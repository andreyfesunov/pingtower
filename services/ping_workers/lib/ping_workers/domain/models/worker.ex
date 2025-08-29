defmodule PingWorkers.Domain.Models.Worker do
  alias PingWorkers.Domain.ValueObjects.Uuid
  alias PingWorkers.Domain.ValueObjects.Url
  alias PingWorkers.Domain.Enums.PeriodType

  defstruct [:id, :url, :period]

  @type t :: %__MODULE__{
          id: Uuid.t(),
          url: Url.t(),
          period: PeriodType.t()
        }

  @spec new(Url.t(), PeriodType.t()) :: t()
  def new(url, period) do
    %__MODULE__{
      id: Uuid.new(),
      url: url,
      period: period
    }
  end
end
