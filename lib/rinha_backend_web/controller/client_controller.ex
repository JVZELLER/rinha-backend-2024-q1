defmodule RinhaBackendWeb.Controller.ClientController do
  @moduledoc """
  Handles requests over clients resources
  """
  import RinhaBackendWeb.JSONView

  alias Plug.Conn
  alias RinhaBackend.Commands.CreateEntry
  alias RinhaBackend.Commands.GetClient
  alias RinhaBackend.Commands.GetClientEntries
  alias RinhaBackend.Schemas.Entry

  @spec create_entry(Conn.t(), map()) :: Conn.t()
  def create_entry(conn, params) do
    client_id = params["id"] || params[:id]

    translated_params = %{
      amount: params["valor"] || params[:valor],
      type: params["tipo"] || params[:tipo],
      description: params["descricao"] || params[:descricao]
    }

    with {:client_id, {client_id, _}} when client_id > 0 <-
           {:client_id, Integer.parse(client_id)},
         translated_params = Map.put(translated_params, :client_id, client_id),
         {:ok, entry} <- Entry.new(translated_params),
         {:ok, result} <- CreateEntry.execute(entry) do
      conn
      |> Conn.put_resp_content_type("application/json")
      |> then(&Conn.send_resp(&1, 200, render!(:show, %{client: result})))
    else
      {:client_id, _error} ->
        Conn.send_resp(conn, 400, "invalid_path_parameter")

      {:error, :invalid_args} ->
        Conn.send_resp(conn, 400, "invalid_args")

      {:error, :client_not_found} ->
        Conn.send_resp(conn, 404, "")

      {:error, :entry_amount_exceeds_client_limit} ->
        Conn.send_resp(conn, 422, "entry_amount_exceeds_client_limit")
    end
  end

  @spec statement(Conn.t(), map()) :: Conn.t()
  def statement(conn, %{"id" => client_id}) do
    with {:client_id, {client_id, _}} when client_id > 0 <-
           {:client_id, Integer.parse(client_id)},
         {:ok, client} <- GetClient.execute(client_id),
         {:ok, entries} <- GetClientEntries.execute(client_id) do
      conn
      |> Conn.put_resp_content_type("application/json")
      |> then(&Conn.send_resp(&1, 200, render!(:statement, %{client: client, entries: entries})))
    else
      {:client_id, _error} ->
        Conn.send_resp(conn, 400, "invalid_path_parameter")

      {:error, :client_not_found} ->
        Conn.send_resp(conn, 404, "")

      {:error, :unexpected} ->
        Conn.send_resp(conn, 500, "")
    end
  end
end
