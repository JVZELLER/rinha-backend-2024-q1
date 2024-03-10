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

  def render!(:statement, %{statement: statement}) do
    now = NaiveDateTime.utc_now()

    %{
      saldo: %{
        total: statement.balance,
        data_extrato: now,
        limite: statement.limit
      },
      ultimas_transacoes: Enum.map(statement.entries, &render_statement_entries/1)
    }
    |> Jason.encode!()
  end

  defp render_statement_entries(entry) do
    %{
      valor: entry.amount,
      tipo: entry.type,
      descricao: entry.description,
      realizada_em: entry.inserted_at
    }
  end
end
