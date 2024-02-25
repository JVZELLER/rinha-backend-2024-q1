defmodule RinhaBackendWeb.Controller.ClientControllerTest do
  use RinhaBackend.ConnCase, async: true

  @body %{valor: 1, tipo: "c", descricao: "aaa"}
  @opts Endpoint.init([])

  describe "create_entry/2" do
    setup do
      {:ok, client_id: insert!(:client, limit: 50)}
    end

    test "should creaty entry successfully", ctx do
      for type <- ~w(c d C D) do
        assert :post
               |> conn("/clientes/#{ctx.client_id}/transacoes", %{@body | tipo: type})
               |> Endpoint.call(@opts)
               |> Map.get(:status) == 200
      end
    end

    test "should return not found when client does not exists" do
      for type <- ~w(c d C D) do
        assert :post
               |> conn("/clientes/123/transacoes", %{@body | tipo: type})
               |> Endpoint.call(@opts)
               |> Map.get(:status) == 404
      end
    end

    test "should return bad request when path parameter is invalid" do
      assert :post
             |> conn("/clientes/abc/transacoes", @body)
             |> Endpoint.call(@opts)
             |> Map.get(:status) == 400
    end

    test "should return bad request when params are invalid", ctx do
      for invalid_arg <- [
            %{tipo: "a"},
            %{descricao: Enum.join(1..11, ".")},
            %{valor: "aa"},
            %{valor: -1},
            %{valor: 0}
          ] do
        invalid_body = Map.merge(@body, invalid_arg)

        assert :post
               |> conn("/clientes/#{ctx.client_id}/transacoes", invalid_body)
               |> Endpoint.call(@opts)
               |> Map.get(:status) == 400
      end
    end

    test "should return unprocessable entity when operation is invalid", ctx do
      assert :post
             |> conn("/clientes/#{ctx.client_id}/transacoes", %{@body | tipo: "d", valor: 100})
             |> Endpoint.call(@opts)
             |> Map.get(:status) == 422
    end
  end

  describe "statement/2" do
    setup do
      client_id = insert!(:client, limit: 50, balance: 12)

      Enum.each(1..12, fn _ ->
        insert!(:entry, client_id: client_id)
        insert!(:entry, type: "c", amount: 2, client_id: client_id)
      end)

      {:ok, client_id: client_id}
    end

    test "should return client's statement successfully", %{client_id: client_id} do
      expected = %{
        "saldo" => %{
          "total" => 12,
          "limite" => 50,
          # To avoid dealing with time travel
          "data_extrato" => nil
        },
        "ultimas_transacoes" => render_transactions(client_id)
      }

      result =
        :get
        |> conn("/clientes/#{client_id}/extrato")
        |> Endpoint.call(@opts)

      json_body = %{"ultimas_transacoes" => transactions} = Jason.decode!(result.resp_body)

      transactions = Enum.map(transactions, &Map.put(&1, "realizada_em", nil))

      result_body =
        json_body
        # To avoid dealing with time travel
        |> put_in(["saldo", "data_extrato"], nil)
        |> Map.put("ultimas_transacoes", transactions)

      assert result.status == 200

      assert expected == result_body
    end

    test "should not found when client does not exists" do
      assert :get
             |> conn("/clientes/901/extrato")
             |> Endpoint.call(@opts)
             |> Map.get(:status) == 404
    end
  end

  defp render_transactions(client_id) do
    "select amount valor, type tipo, description descricao, null as realizada_em from entries where client_id = #{client_id} limit 10"
    |> Repo.query!()
    |> then(&(&1.rows |> Enum.map(fn line -> Enum.zip(&1.columns, line) |> Map.new() end)))
  end
end
