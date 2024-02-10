import Config

if config_env() != :prod do
  import_config("dev.exs")
end
