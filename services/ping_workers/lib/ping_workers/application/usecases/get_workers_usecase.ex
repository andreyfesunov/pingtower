defmodule PingWorkers.Application.Usecases.GetWorkersUsecase do
  @moduledoc """
  Usecase for getting paged workers.
  """

  alias PingWorkers.Application.Commands.GetWorkersCommand
  alias PingWorkers.Domain.Models.Pagination
  alias PingWorkers.Domain.Models.Worker
  alias PingWorkers.Infrastructure.Repositories.WorkerRepository

  @spec handle(GetWorkersCommand.t()) :: {:ok, Pagination.t(Worker.t())} | {:error, String.t()}
  def handle(command) do
    WorkerRepository.query(command.page, command.page_size)
  end
end
