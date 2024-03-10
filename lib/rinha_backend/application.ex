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
        # render_executors(),
        {DynamicSupervisor, strategy: :one_for_one, name: RinhaBackend.ClientRunner},
        {Plug.Cowboy, scheme: :http, plug: RinhaBackendWeb.Endpoint, options: [port: 4000]}
        # {Bandit, plug: RinhaBackendWeb.Endpoint, port: 4000}
      ]
      |> List.flatten()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RinhaBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # defp render_executors do
  #   concurrency = Application.fetch_env!(:rinha_backend, :concurrency)

  #   Enum.map(1..concurrency, fn i ->
  #     %{
  #       id: :"RinhaBackend.GenServers.Executor#{i}",
  #       start: {RinhaBackend.GenServers.Executor, :start_link, [[client_id: i]]}
  #     }
  #   end)
  # end
end
