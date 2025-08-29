defmodule PingWorkers.Presentation.Mappers.WorkerMapper do
  alias PingWorkers.Domain.Models.Worker
  alias PingWorkers.Presentation.Models.WorkerModel

  @spec map(Worker.t()) :: WorkerModel.t()
  def map(model) do
    WorkerModel.new(
      to_string(model.id),
      to_string(model.url),
      to_string(model.period)
    )
  end
end
