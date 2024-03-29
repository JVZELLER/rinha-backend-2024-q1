defmodule RinhaBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        RinhaBackend.PromEx,
        RinhaBackend.Repo,
        RinhaBackend.ReadRepo,
        {DynamicSupervisor, strategy: :one_for_one, name: RinhaBackend.BackPressureSupervisor},
        {Plug.Cowboy, scheme: :http, plug: RinhaBackendWeb.Endpoint, options: [port: 4000]}
        # {Bandit, plug: RinhaBackendWeb.Endpoint, port: 4000}
      ]
      |> List.flatten()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RinhaBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
