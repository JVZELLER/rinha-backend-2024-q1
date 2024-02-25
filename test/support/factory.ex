defmodule RinhaBackend.Factory do
  @moduledoc """
  Helper module to define test fixtures
  """
  alias RinhaBackend.Repo

  def insert!(name, args \\ [])

  def insert!(:client, args) do
    now = NaiveDateTime.utc_now()
    default = [balance: 0, limit: 10, inserted_at: now, updated_at: now]

    {1, [%{id: id}]} =
      default
      |> Keyword.merge(args)
      |> then(&Repo.insert_all("clients", [&1], returning: [:id]))

    id
  end

  def insert!(:entry, args) do
    now = NaiveDateTime.utc_now()
    default = [amount: 1, type: "d", description: "Elixir in Action", inserted_at: now]

    {1, [%{id: id}]} =
      default
      |> Keyword.merge(args)
      |> then(&Repo.insert_all("entries", [&1], returning: [:id]))

    id
  end
end
