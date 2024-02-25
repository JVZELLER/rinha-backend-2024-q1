defmodule Commands.GetClientTest do
  use RinhaBackend.DataCase, async: true

  alias RinhaBackend.Commands.GetClient
  alias RinhaBackend.Schemas.Client

  describe "execute/1" do
    setup do
      {:ok, client_id: insert!(:client, balance: 10, limit: 1)}
    end

    test "should return client successfully", %{client_id: client_id} do
      expected = struct(Client, %{id: client_id, balance: 10, limit: 1})
      assert GetClient.execute(client_id) == {:ok, expected}
    end

    test "should return error when client does not exists" do
      assert GetClient.execute(999) == {:error, :client_not_found}
    end
  end
end
