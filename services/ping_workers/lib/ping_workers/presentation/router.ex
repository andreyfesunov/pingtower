defmodule PingWorkers.Presentation.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  forward("/apis", to: PingWorkers.Presentation.ApisRouter)
  forward("/urls", to: PingWorkers.Presentation.UrlsRouter)

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
