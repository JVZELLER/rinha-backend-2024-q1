defmodule RinhaBackend.Factory do
  @moduledoc """
  Helper module to define test fixtures
  """
  alias RinhaBackend.Repo

  def insert!(:client, args \\ []) do
    now = NaiveDateTime.utc_now()

    {1, [%{id: id}]} =
      args
      |> Keyword.merge(balance: 0, limit: 10, inserted_at: now, updated_at: now)
      |> then(&Repo.insert_all("clients", [&1], returning: [:id]))

    id
  end
end
