defmodule PingWorkers.Presentation.Routers.WorkersRouter do
  @moduledoc """
  Router for workers.
  """

  use Plug.Router

  alias PingWorkers.Application.Usecases.GetWorkersUsecase
  alias PingWorkers.Domain.Models.Pagination
  alias PingWorkers.Presentation.Mappers.GetUrlsRequestMapper
  alias PingWorkers.Presentation.Mappers.WorkerMapper
  alias PingWorkers.Presentation.Requests.GetUrlsRequestModel

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/" do
    case GetUrlsRequestModel.new(conn.query_params) do
      {:error, reason} ->
        send_resp(conn, 400, Jason.encode!(%{error: reason}))

      {:ok, model} ->
        case model |> GetUrlsRequestMapper.map() |> GetWorkersUsecase.handle() do
          {:error, reason} ->
            send_resp(conn, 500, Jason.encode!(%{error: reason}))

          {:ok, pagination} ->
            send_resp(
              conn,
              200,
              Jason.encode!(Pagination.mapped(pagination, &WorkerMapper.map/1))
            )
        end
    end
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
