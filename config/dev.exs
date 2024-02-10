import Config

config :crebito, App.Repo,
  database: "crebito",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :crebito, http_port: String.to_integer(System.get_env("PORT") || "4000")
