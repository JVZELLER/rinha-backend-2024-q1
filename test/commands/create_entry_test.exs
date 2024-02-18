defmodule Commands.CreateEntryTest do
  use RinhaBackend.DataCase, async: true

  alias RinhaBackend.Commands.CreateEntry
  alias RinhaBackend.Schemas.Entry

  describe "execute/1" do
    setup do
      now = NaiveDateTime.utc_now()

      Repo.insert_all("clients", [
        [id: 1, balance: 0, limit: 10, inserted_at: now, updated_at: now]
      ])

      base = %{amount: 1, type: "c", description: "Elixir", client_id: 1}

      {:ok, debit: Entry.new(%{base | type: "d"}), credit: Entry.new(base)}
    end

    test "should create entry successfully", ctx do
      assert CreateEntry.execute(1, ctx.debit) == {:ok, %{"balance" => -1, "limit" => 10}}
      assert CreateEntry.execute(1, ctx.credit) == {:ok, %{"balance" => 0, "limit" => 10}}
    end

    test "should return error when client does not exists", ctx do
      assert CreateEntry.execute(2, ctx.debit) == {:error, :client_not_found}
    end

    test "should return error when entry amount exceeds client's limit", ctx do
      entry = %{ctx.debit | amount: 11}

      assert CreateEntry.execute(2, entry) == {:error, :client_not_found}
    end
  end
end
