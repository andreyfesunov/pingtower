defmodule PingWorkers.Application.Usecases.CreateWorkerUsecase do
  @moduledoc """
  Usecase, that creates `Worker`.
  """

  alias PingWorkers.Application.Commands.CreateWorkerCommand
  alias PingWorkers.Domain.Models.Worker

  @spec handle(CreateWorkerCommand.t()) :: Worker.t()
  def handle(command) do
    Worker.new(command.url, command.period)
  end
end
