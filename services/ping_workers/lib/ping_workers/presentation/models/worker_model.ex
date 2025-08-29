defmodule PingWorkers.Presentation.Models.WorkerModel do
  defstruct [:id, :url, :period]

  @type t :: %__MODULE__{
          id: String.t(),
          url: String.t(),
          period: String.t()
        }

  @spec new(Uuid.t(), Url.t(), PeriodType.t()) :: t()
  def new(id, url, period) do
    %__MODULE__{
      id: to_string(id),
      url: to_string(url),
      period: to_string(period)
    }
  end
end

defimpl Jason.Encoder, for: PingWorkers.Presentation.Models.WorkerModel do
  alias PingWorkers.Presentation.Models.WorkerModel

  def encode(%WorkerModel{} = model, opts) do
    Jason.Encode.map(model, opts)
  end
end
