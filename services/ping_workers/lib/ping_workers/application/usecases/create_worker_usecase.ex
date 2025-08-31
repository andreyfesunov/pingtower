defmodule PingWorkers.Application.Usecases.CreateWorkerUsecase do
  @moduledoc """
  Usecase for creating a worker.
  """

  alias PingWorkers.Application.Commands.CreateWorkerCommand
  alias PingWorkers.Domain.Models.Worker
  alias PingWorkers.Infrastructure.Repositories.WorkerRepository

  @doc """
  Creates a worker from command.
  """
  @spec handle(CreateWorkerCommand.t()) :: {:ok, Worker.t()} | {:error, String.t()}
  def handle(command) do
    worker = Worker.new(command.url, command.period)

    case WorkerRepository.exists(worker) do
      {:error, reason} -> {:error, reason}
      {:ok, true} -> {:error, "Worker with provided URL already exists."}
      {:ok, false} -> WorkerRepository.create(worker)
    end
  end
end
