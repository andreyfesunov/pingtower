defmodule PingWorkers.Presentation.Routers.UrlsRouter do
  @moduledoc """
  Router for URLs.
  """

  alias PingWorkers.Application.Usecases.CreateWorkerUsecase
  alias PingWorkers.Presentation.Mappers.CreateUrlRequestMapper
  alias PingWorkers.Presentation.Mappers.WorkerMapper
  alias PingWorkers.Presentation.Requests.CreateUrlRequestModel

  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "urls")
  end

  post "/" do
    case CreateUrlRequestModel.new(conn.body_params) do
      {:error, reason} ->
        conn
        |> send_resp(400, Jason.encode!(%{error: reason}))

      {:ok, request} ->
        command = CreateUrlRequestMapper.map(request)

        case CreateWorkerUsecase.handle(command) do
          {:ok, worker} ->
            conn
            |> send_resp(201, Jason.encode!(%{data: WorkerMapper.map(worker)}))

          {:error, reason} ->
            conn
            |> send_resp(500, Jason.encode!(%{error: reason}))
        end
    end
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
