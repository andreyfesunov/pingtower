defmodule PingWorkers.Application do
  @moduledoc """
  Application for PingWorkers.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {PingWorkers.Infrastructure.Facades.MongodbFacade, []},
      {Plug.Cowboy,
       scheme: :http, plug: PingWorkers.Presentation.Routers.Router, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: PingWorkers.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    {:ok, _} = Application.ensure_all_started(:mongodb_driver)

    {:ok, pid}
  end
end
