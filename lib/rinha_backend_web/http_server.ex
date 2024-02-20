defmodule RinhaBackendWeb.HTTPServer do
  @moduledoc """
  The application web server
  """
  use Plug.Router

  alias RinhaBackendWeb.Controller.ClientController

  plug(:match)

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
    send_resp(conn, 501, "")
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
