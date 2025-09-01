defmodule PingWorkers.Presentation.Routers.Router do
  @moduledoc """
  Router for the application.
  """

  use Plug.Router

  plug(CORSPlug)
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  forward("/apis", to: PingWorkers.Presentation.Routers.ApisRouter)
  forward("/urls", to: PingWorkers.Presentation.Routers.UrlsRouter)
  forward("/workers", to: PingWorkers.Presentation.Routers.WorkersRouter)

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
