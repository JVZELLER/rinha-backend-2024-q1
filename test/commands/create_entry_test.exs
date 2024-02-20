defmodule Commands.CreateEntryTest do
  use RinhaBackend.DataCase, async: true

  alias RinhaBackend.Commands.CreateEntry
  alias RinhaBackend.Schemas.Entry

  describe "execute/1" do
    setup do
      client_id = insert!(:client)

      base = %{amount: 1, type: "c", description: "Elixir", client_id: client_id}

      {:ok, debit} = Entry.new(%{base | type: "d"})
      {:ok, credit} = Entry.new(base)

      {:ok, debit: debit, credit: credit}
    end

    test "should create entry successfully", ctx do
      assert CreateEntry.execute(ctx.debit) == {:ok, %{"balance" => -1, "limit" => 10}}
      assert CreateEntry.execute(ctx.credit) == {:ok, %{"balance" => 0, "limit" => 10}}
    end

    test "should return error when client does not exists", ctx do
      assert CreateEntry.execute(%{ctx.debit | client_id: 123}) == {:error, :client_not_found}
    end

    test "should return error when entry amount exceeds client's limit", ctx do
      entry = %{ctx.debit | amount: -11}

      assert CreateEntry.execute(entry) == {:error, :entry_amount_exceeds_client_limit}
    end
  end
end
