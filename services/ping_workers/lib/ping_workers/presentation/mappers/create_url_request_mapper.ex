defmodule PingWorkers.Presentation.Mappers.CreateUrlRequestMapper do
  alias PingWorkers.Application.Commands.CreateWorkerCommand
  alias PingWorkers.Presentation.Requests.CreateUrlRequestModel

  @spec map(CreateUrlRequestModel.t()) :: CreateWorkerCommand.t()
  def map(model) do
    CreateWorkerCommand.new(model.url, model.period)
  end
end
