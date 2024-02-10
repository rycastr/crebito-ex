defmodule App.Application do
  use Application

  @impl true
  def start(_type, _args) do
    http_port = Application.get_env(:crebito, :http_port)

    children = [
      {Plug.Cowboy, scheme: :http, plug: App.Router, options: [port: http_port]},
      App.Repo
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
