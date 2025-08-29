defmodule PingWorkers.Presentation.Routers.UrlsRouter do
  alias PingWorkers.Presentation.Mappers.WorkerMapper
  alias PingWorkers.Application.Usecases.CreateWorkerUsecase
  alias PingWorkers.Presentation.Requests.CreateUrlRequestModel
  alias PingWorkers.Presentation.Mappers.CreateUrlRequestMapper

  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "apis")
  end

  post "/" do
    case CreateUrlRequestModel.new(conn.body_params) do
      {:error, reason} ->
        conn
        |> send_resp(
          400,
          Jason.encode!(%{
            error: reason
          })
        )

      {:ok, request} ->
        worker =
          CreateUrlRequestMapper.map(request)
          |> CreateWorkerUsecase.handle()
          |> WorkerMapper.map()

        conn
        |> send_resp(
          201,
          Jason.encode!(%{
            data: worker
          })
        )
    end
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
