defmodule RinhaBackend.Commands.GetClientEntries do
  @moduledoc """
  Commando for getting client's entries
  """
  alias RinhaBackend.Schemas.Entry
  alias RinhaBackend.ReadRepo

  @telemetry_execution_event ~w(rinha_backend domain execution)a

  @spec execute(non_neg_integer(), non_neg_integer()) ::
          {:ok, [Entry.t()]} | {:error, :unexpected}
  def execute(client_id, limit \\ 10) do
    start = System.monotonic_time(:microsecond)

    ~s/
    SELECT amount
      , type
      , description
      , inserted_at
    FROM entries
    where client_id = #{client_id}
    order by inserted_at desc
    limit #{limit};
    /
    |> ReadRepo.query()
    |> case do
      {:ok, %Postgrex.Result{rows: rows}} ->
        {:ok, render(rows)}

      _error ->
        {:error, :unexpected}
    end
    |> tap(fn _ ->
      :telemetry.execute(
        @telemetry_execution_event,
        %{total_time: System.monotonic_time(:microsecond) - start},
        %{
          client_id: client_id,
          name: :get_entries,
          instance: Application.fetch_env!(:rinha_backend, :instance)
        }
      )
    end)
  end

  defp render(rows) do
    Enum.map(rows, fn [amount, type, desc, inserted_at] ->
      params = %{amount: amount, type: type, description: desc, inserted_at: inserted_at}

      struct(Entry, params)
    end)
  end
end
