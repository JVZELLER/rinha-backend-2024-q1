defmodule RinhaBackend.Commands.GetClient do
  @moduledoc """
  Command for getting current client's balance and limit
  """
  alias RinhaBackend.Repo
  alias RinhaBackend.Schemas.Client

  @spec execute(non_neg_integer()) :: {:ok, Client.t()} | {:error, :client_not_found}
  def execute(client_id) do
    ~s/
    SELECT balance
      , "limit"
    FROM clients
    WHERE id = $1;
    /
    |> Repo.query([client_id])
    |> case do
      {:ok, %Postgrex.Result{rows: [_ | _] = rows}} ->
        [balance, limit] = List.flatten(rows)

        {:ok, struct(Client, %{id: client_id, balance: balance, limit: limit})}

      {:ok, %Postgrex.Result{rows: []}} ->
        {:error, :client_not_found}
    end
  end
end
