import Config

config :rinha_backend, ecto_repos: [RinhaBackend.Repo]

config :rinha_backend, RinhaBackend.Repo,
  database: "rinha",
  username: "admin",
  password: "123",
  hostname: "localhost"
