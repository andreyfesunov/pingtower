defmodule PingWorkers.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: PingWorkers.Presentation.Router, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: PingWorkers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
