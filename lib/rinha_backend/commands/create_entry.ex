defmodule RinhaBackend.Commands.CreateEntry do
  @moduledoc """
  Command for creating an entry for a given client.
  """
  alias RinhaBackend.Repo
  alias RinhaBackend.Schemas.Entry

  @spec execute(Entry.t()) ::
          {:ok, map()}
          | {:error, :client_not_found}
          | {:error, :entry_amount_exceeds_client_limit}
  def execute(entry) do
    amount = if(entry.type == "d", do: entry.amount * -1, else: entry.amount)

    "select fn_insert_entry($1, $2, $3, $4)"
    |> Repo.query([
      amount,
      entry.type,
      entry.description,
      entry.client_id
    ])
    |> case do
      {:ok, %Postgrex.Result{rows: rows}} ->
        {:ok, rows |> List.flatten() |> List.first()}

      {:error, %Postgrex.Error{postgres: %{message: "client_not_found"}}} ->
        {:error, :client_not_found}

      {:error, %Postgrex.Error{postgres: %{message: "entry_amount_exceeds_client_limit"}}} ->
        {:error, :entry_amount_exceeds_client_limit}
    end
  end
end
