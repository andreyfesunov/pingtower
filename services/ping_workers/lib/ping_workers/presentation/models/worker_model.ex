defmodule PingWorkers.Presentation.Models.WorkerModel do
  defstruct [:id, :url, :period]

  @type t :: %__MODULE__{
          id: String.t(),
          url: String.t(),
          period: String.t()
        }

  @spec new(String.t(), String.t(), String.t()) :: t()
  def new(id, url, period) do
    %__MODULE__{
      id: id,
      url: url,
      period: period
    }
  end
end

defimpl Jason.Encoder, for: PingWorkers.Presentation.Models.WorkerModel do
  alias PingWorkers.Presentation.Models.WorkerModel

  def encode(%WorkerModel{} = model, opts) do
    model
    |> Map.from_struct()
    |> Map.delete(:__struct__)
    |> Jason.Encode.map(opts)
  end
end
