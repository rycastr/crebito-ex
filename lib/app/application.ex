defmodule App.Application do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info(
      "Starting with #{:erlang.system_info(:schedulers_online)} threads"
    )

    http_port = Application.get_env(:crebito, :http_port)

    children = [
      {Plug.Cowboy, scheme: :http, plug: Infra.Router, options: [port: http_port]},
      App.Repo
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
