defmodule App.Repo do
  use Ecto.Repo,
    otp_app: :crebito,
    adapter: Ecto.Adapters.Postgres
end
