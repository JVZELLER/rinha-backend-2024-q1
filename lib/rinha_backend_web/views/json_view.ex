defmodule RinhaBackendWeb.JSONView do
  @moduledoc """
  Defines the JSON view for clients resources.
  """

  @spec render!(atom(), map()) :: String.t() | no_return()
  def render!(:show, %{client: client}) do
    %{
      limite: client[:limit] || client["limit"],
      saldo: client[:balance] || client["balance"]
    }
    |> Jason.encode!()
  end

  def render!(:statement, %{client: client, entries: entries}) do
    now = NaiveDateTime.utc_now()

    %{
      saldo: %{
        total: client.balance,
        data_extrato: now,
        limite: client.limit
      },
      ultimas_transacoes: Enum.map(entries, &render_statement_entries/1)
    }
    |> Jason.encode!()
  end

  defp render_statement_entries(entry) do
    %{
      valor: abs(entry.amount),
      tipo: entry.type,
      descricao: entry.description,
      realizada_em: entry.inserted_at
    }
  end
end
