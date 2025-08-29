defmodule PingWorkers.Application.Usecases.CreateWorkerUsecase do
  alias PingWorkers.Domain.Models.Worker
  alias PingWorkers.Application.Commands.CreateWorkerCommand

  @spec handle(CreateWorkerCommand.t()) :: Worker.t()
  def handle(command) do
    Worker.new(command.url, command.period)
  end
end
