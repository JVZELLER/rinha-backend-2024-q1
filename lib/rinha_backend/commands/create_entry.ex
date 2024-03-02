defmodule RinhaBackend.Commands.CreateEntry do
  @moduledoc """
  Command for creating an entry for a given client.
  """
  alias RinhaBackend.Repo
  alias RinhaBackend.Schemas.Entry

  @telemetry_execution_event ~w(rinha_backend domain execution)a

  @spec execute(Entry.t()) ::
          {:ok, map()}
          | {:error, :client_not_found}
          | {:error, :entry_amount_exceeds_client_limit}
  def execute(entry) do
    start = System.monotonic_time(:microsecond)

    "select fn_insert_entry($1, $2, $3, $4)"
    |> Repo.query([
      entry.amount,
      entry.type,
      entry.description,
      String.to_integer(entry.client_id)
    ])
    |> case do
      {:ok, %Postgrex.Result{rows: rows}} ->
        {:ok, rows |> List.flatten() |> List.first()}

      {:error, %Postgrex.Error{postgres: %{message: "client_not_found"}}} ->
        {:error, :client_not_found}

      {:error, %Postgrex.Error{postgres: %{message: "entry_amount_exceeds_client_limit"}}} ->
        {:error, :entry_amount_exceeds_client_limit}
    end
    |> tap(fn _ ->
      :telemetry.execute(
        @telemetry_execution_event,
        %{total_time: System.monotonic_time(:microsecond) - start, name: :create_entry},
        %{
          client_id: entry.client_id,
          name: :create_entry,
          instance: Application.fetch_env!(:rinha_backend, :instance)
        }
      )
    end)
  end
end
