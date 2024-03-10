defmodule RinhaBackendWeb.Controller.ClientController do
  @moduledoc """
  Handles requests over clients resources
  """
  import RinhaBackendWeb.JSONView

  alias Plug.Conn
  alias RinhaBackend.Commands.CreateEntry
  alias RinhaBackend.Commands.GetClientEntries
  alias RinhaBackend.GenServers.BackPressure
  alias RinhaBackend.Schemas.Entry

  @spec create_entry(Conn.t(), map()) :: Conn.t()
  def create_entry(conn, params) do
    client_id = params["id"] || params[:id]

    translated_params = %{
      amount: params["valor"] || params[:valor],
      type: params["tipo"] || params[:tipo],
      description: params["descricao"] || params[:descricao]
    }

    with translated_params = Map.put(translated_params, :client_id, client_id),
         {:ok, entry} <- Entry.new(translated_params),
         {:ok, result} <- do_create_entry(client_id, entry) do
      conn
      |> Conn.put_resp_content_type("application/json")
      |> Conn.send_resp(200, render!(:show, %{client: result}))
    else
      {:error, :timeout} ->
        Conn.send_resp(conn, 503, "service_unavailable")

      {:client_id, _error} ->
        Conn.send_resp(conn, 400, "invalid_path_parameter")

      {:error, :invalid_args} ->
        Conn.send_resp(conn, 422, "invalid_args")

      {:error, :client_not_found} ->
        Conn.send_resp(conn, 404, "")

      {:error, :entry_amount_exceeds_client_limit} ->
        Conn.send_resp(conn, 422, "entry_amount_exceeds_client_limit")
    end
  end

  @spec statement(Conn.t(), map()) :: Conn.t()
  def statement(conn, %{"id" => client_id}) do
    client_id
    |> GetClientEntries.execute()
    |> case do
      {:ok, statement} ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, render!(:statement, %{statement: statement}))

      {:client_id, _error} ->
        Conn.send_resp(conn, 400, "invalid_path_parameter")

      {:error, :client_not_found} ->
        Conn.send_resp(conn, 404, "")
    end
  end

  defp do_create_entry(client_id, entry) do
    if back_pressure_enabled?() do
      BackPressure.execute(client_id, entry)
    else
      CreateEntry.execute(entry)
    end
  end

  defp back_pressure_enabled?,
    do: :rinha_backend |> Application.fetch_env!(:back_pressure) |> Keyword.fetch!(:enabled?)
end
