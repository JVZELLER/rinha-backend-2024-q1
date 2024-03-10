import Config

fetch_env! = fn
  {name, ""} ->
    System.fetch_env!(name)

  {name, help} ->
    System.get_env(name) ||
      raise """
      environment variable #{name} is missing.

      #{help}
      """

  name ->
    System.fetch_env!(name)
end

fetch_int! = fn conf ->
  conf |> fetch_env!.() |> String.to_integer()
end

fetch_bool! = fn conf ->
  fetch_env!.(conf) == "true"
end

config :rinha_backend, RinhaBackend.ReadRepo,
  database: fetch_env!.("DATABASE_NAME"),
  username: fetch_env!.("DATABASE_USER"),
  password: fetch_env!.("DATABASE_PASS"),
  hostname: fetch_env!.("DATABASE_HOST"),
  pool_size: fetch_int!.("READ_DATABSE_POOL_SIZE"),
  # queue_target: fetch_int!.("ECTO_QUEUE_TARGET"),
  # queue_interval: fetch_int!.("ECTO_QUEUE_INTERVAL"),
  timeout: fetch_int!.("ECTO_REPO_TIMEOUT")

config :rinha_backend, RinhaBackend.Repo,
  database: fetch_env!.("DATABASE_NAME"),
  username: fetch_env!.("DATABASE_USER"),
  password: fetch_env!.("DATABASE_PASS"),
  hostname: fetch_env!.("DATABASE_HOST"),
  pool_size: fetch_int!.("DATABSE_POOL_SIZE"),
  queue_target: fetch_int!.("ECTO_QUEUE_TARGET"),
  queue_interval: fetch_int!.("ECTO_QUEUE_INTERVAL"),
  timeout: fetch_int!.("ECTO_REPO_TIMEOUT")

config :rinha_backend, instance: fetch_env!.("APP_INSTANCE")

config :rinha_backend, :back_pressure,
  enabled?: fetch_bool!.("BACK_PRESSURE"),
  max_concurrency: fetch_int!.("CONCURRENCY"),
  timeout_in_ms: "TIMEOUT_IN_SECONDS" |> fetch_int!.() |> :timer.seconds() |> ceil(),
  dispatch_timeout_in_ms: fetch_int!.("DISPATCH_TIMEOUT_IN_MS")
