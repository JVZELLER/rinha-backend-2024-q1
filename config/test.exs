import Config

config :rinha_backend, RinhaBackend.Repo, pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warning

# Capture tests logs
config :ex_unit, capture_log: true
