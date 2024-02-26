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

config :rinha_backend, RinhaBackend.Repo,
  database: fetch_env!.("DATABASE_NAME"),
  username: fetch_env!.("DATABASE_USER"),
  password: fetch_env!.("DATABASE_PASS"),
  hostname: fetch_env!.("DATABASE_HOST"),
  pool_size: fetch_int!.("DATABSE_POOL_SIZE")
