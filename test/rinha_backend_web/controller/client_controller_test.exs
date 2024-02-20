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
end
