defmodule RinhaBackend.Commands.GetClientEntries do
  @moduledoc """
  Commando for getting client's entries
  """
  alias RinhaBackend.Schemas.Entry
  alias RinhaBackend.Repo

  @spec execute(non_neg_integer(), non_neg_integer()) ::
          {:ok, [Entry.t()]} | {:error, :unexpected}
  def execute(client_id, limit \\ 10) do
    ~s/
    SELECT amount
      , type
      , description
      , inserted_at
    FROM entries
    where client_id = $1
    order by inserted_at
    limit $2;
    /
    |> Repo.query([client_id, limit])
    |> case do
      {:ok, %Postgrex.Result{rows: rows}} ->
        {:ok, render(rows)}

      _error ->
        {:error, :unexpected}
    end
  end

  defp render(rows) do
    Enum.map(rows, fn [amount, type, desc, inserted_at] ->
      params = %{amount: amount, type: type, description: desc, inserted_at: inserted_at}

      struct(Entry, params)
    end)
  end
end
