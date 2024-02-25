import Config

config :rinha_backend, ecto_repos: [RinhaBackend.Repo]

config :rinha_backend, RinhaBackend.Repo,
  database: "rinha",
  username: "admin",
  password: "123",
  hostname: "localhost",
  pool_size: 100,
  parameters: [application_name: "rinha_backend"]

# Configures Elixir's Logger
config :logger, :console, format: "$time $metadata[$level] $message\n"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
