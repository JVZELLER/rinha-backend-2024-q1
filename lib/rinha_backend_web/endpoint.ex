defmodule RinhaBackendWeb.Endpoint do
  @moduledoc """
  A plug responsible for parsing request body's as JSON, matching routes, and dispatching responses.
  """
  use Plug.Router

  alias RinhaBackendWeb.Controller.ClientController

  plug(:match)
  plug(PromEx.Plug, prom_ex_module: RinhaBackend.PromEx)
  plug(Plug.Telemetry, event_prefix: [:rinha_backend, :bandit, :endpoint])

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/clientes/:id/transacoes" do
    ClientController.create_entry(conn, Map.put(conn.body_params, "id", id))
  end

  get "/clientes/:id/extrato" do
    ClientController.statement(conn, Map.put(conn.body_params, "id", id))
  end

  match _ do
    send_resp(conn, 404, "not_found")
  end
end
