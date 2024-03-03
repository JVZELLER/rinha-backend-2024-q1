defmodule RinhaBackend.GenServers.Executor do
  @moduledoc """
  GenServer to controll concurrency on create_entry execution in the database.

  The idea is to serialize insert_entry and client_updates to avoid lock wait time in the DB.
  """
  use GenServer

  alias RinhaBackend.ClientRunner
  alias RinhaBackend.Commands.CreateEntry

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args) do
    {:ok, client_id} = Keyword.fetch(args, :id)

    GenServer.start_link(__MODULE__, args, name: :"client_#{client_id}")
  end

  @impl true
  def init(_init_arg) do
    {:ok, :ok}
  end

  ############
  ## Client ##
  ############

  def create_entry(client_id, args) do
    start_client_server(client_id)
    GenServer.call(:"client_#{client_id}", {:create_entry, args})
  end

  defp start_client_server(client_id) do
    :"client_#{client_id}"
    |> Process.whereis()
    |> case do
      nil -> DynamicSupervisor.start_child(ClientRunner, {__MODULE__, [id: client_id]})
      _ -> :ok
    end
  end

  ############
  ## Server ##
  ############

  @impl true
  def handle_call({:create_entry, args}, _from, _state) do
    result = CreateEntry.execute(args)
    {:reply, result, result}
  end
end
