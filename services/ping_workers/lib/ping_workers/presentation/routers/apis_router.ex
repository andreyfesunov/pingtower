defmodule PingWorkers.Presentation.Routers.ApisRouter do
  @moduledoc """
  Router for APIs.
  """

  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "apis")
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
