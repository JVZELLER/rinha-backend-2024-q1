defmodule RinhaBackend.Commands.GetClientEntries do
  @moduledoc """
  Commando for getting client's entries
  """
  import Ecto.Query

  alias RinhaBackend.Schemas.Client
  alias RinhaBackend.Schemas.Entry
  alias RinhaBackend.ReadRepo

  @spec execute(non_neg_integer(), non_neg_integer()) ::
          {:ok, Client.t()} | {:error, :client_not_found}
  def execute(client_id, limit \\ 10) do
    entries_query =
      Entry
      |> where(client_id: type(^client_id, :integer))
      |> limit(^limit)
      |> order_by(desc: :inserted_at)

    Client
    |> where(id: type(^client_id, :integer))
    |> preload(entries: ^entries_query)
    |> ReadRepo.one()
    |> case do
      nil ->
        {:error, :client_not_found}

      client ->
        {:ok, client}
    end
  end
end
