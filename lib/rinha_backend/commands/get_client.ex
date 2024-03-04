defmodule RinhaBackend.Commands.GetClient do
  @moduledoc """
  Command for getting current client's balance and limit
  """
  alias RinhaBackend.ReadRepo
  alias RinhaBackend.Schemas.Client

  @telemetry_execution_event ~w(rinha_backend domain execution)a

  @spec execute(non_neg_integer()) :: {:ok, Client.t()} | {:error, :client_not_found}
  def execute(client_id) do
    start = System.monotonic_time(:microsecond)

    ~s/
    SELECT balance
      , "limit"
    FROM clients
    WHERE id = #{client_id};
    /
    |> ReadRepo.query()
    |> case do
      {:ok, %Postgrex.Result{rows: [_ | _] = rows}} ->
        [balance, limit] = List.flatten(rows)

        {:ok, struct(Client, %{id: client_id, balance: balance, limit: limit})}

      {:ok, %Postgrex.Result{rows: []}} ->
        {:error, :client_not_found}
    end
    |> tap(fn _ ->
      :telemetry.execute(
        @telemetry_execution_event,
        %{total_time: System.monotonic_time(:microsecond) - start},
        %{
          client_id: client_id,
          name: :get_client,
          instance: Application.fetch_env!(:rinha_backend, :instance)
        }
      )
    end)
  end
end
