defmodule Commands.GetClientEntriesTest do
  use RinhaBackend.DataCase, async: true

  alias RinhaBackend.Commands.GetClientEntries
  alias RinhaBackend.Schemas.Entry

  describe "execute/1" do
    setup do
      client_id = insert!(:client, balance: 10, limit: 1)
      insert!(:entry, type: "d", client_id: client_id, description: "aa")
      insert!(:entry, type: "c", client_id: client_id, description: "aa")

      {:ok, client_id: client_id}
    end

    test "should return client's entries successfully", %{client_id: client_id} do
      base = %{amount: 1, description: "aa", type: nil}

      expected =
        [%{base | type: "d"}, %{base | type: "c"}]
        |> Enum.map(&struct(Entry, &1))
        |> MapSet.new()

      assert {:ok, result} = GetClientEntries.execute(client_id)

      assert result
             |> Enum.map(&Map.put(&1, :inserted_at, nil))
             |> MapSet.new()
             |> MapSet.equal?(expected)
    end

    test "should limit the number of returned entries", %{client_id: client_id} do
      assert {:ok, result} = GetClientEntries.execute(client_id, 1)
      assert length(result) == 1
    end

    test "should return empty list when client does not exists" do
      assert GetClientEntries.execute(999) == {:ok, []}
    end
  end
end
