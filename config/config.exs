import Config

config :rinha_backend, ecto_repos: [RinhaBackend.Repo]

config :rinha_backend, RinhaBackend.Repo, parameters: [application_name: "rinha_backend"]

# Configures Elixir's Logger
config :logger, :console, format: "$time $metadata[$level] $message\n"

if config_env() != :prod do
  Code.eval_file("runtime_defaults.exs", __DIR__)
  import_config "runtime.exs"
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
