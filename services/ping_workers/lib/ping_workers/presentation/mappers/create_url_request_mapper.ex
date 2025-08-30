defmodule PingWorkers.Presentation.Mappers.CreateUrlRequestMapper do
  @moduledoc """
  Mapper for create url request.

  The module contains function to map `CreateUrlRequestModel` to `CreateWorkerCommand`.
  """

  alias PingWorkers.Application.Commands.CreateWorkerCommand
  alias PingWorkers.Presentation.Requests.CreateUrlRequestModel

  @spec map(CreateUrlRequestModel.t()) :: CreateWorkerCommand.t()
  def map(model) do
    CreateWorkerCommand.new(model.url, model.period)
  end
end
