defmodule RinhaBackend.GenServers.Executor do
  @moduledoc """
  GenServer to controll concurrency on create_entry execution in the database.

  The idea is to serialize insert_entry and client_updates to avoid lock wait time in the DB.
  """
  use GenServer

  # alias RinhaBackend.ClientRunner
  alias RinhaBackend.Commands.CreateEntry

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args) do
    {:ok, id} = Keyword.fetch(args, :client_id)

    GenServer.start_link(__MODULE__, args, name: :"client_#{id}")
  end

  @impl true
  def init(_init_arg) do
    {:ok, :ok}
  end

  ############
  ## Client ##
  ############

  def create_entry(_client_id, args) do
    # start_client_server(client_id)
    concurrency = Application.get_env(:rinha_backend, :concurrency, 5)
    client_id = Enum.random(1..concurrency)
    GenServer.cast(:"client_#{client_id}", {:create_entry, self(), args})

    receive do
      {:result, result} ->
        result
    after
      :timer.seconds(5) ->
        {:error, "timeout"}
    end
  end

  # defp start_client_server(client_id) do
  #   :"client_#{client_id}"
  #   |> Process.whereis()
  #   |> case do
  #     nil -> DynamicSupervisor.start_child(ClientRunner, {__MODULE__, [id: client_id]})
  #     _ -> :ok
  #   end
  # end

  ############
  ## Server ##
  ############

  @impl true
  def handle_cast({:create_entry, from, args}, _state) do
    result = CreateEntry.execute(args)

    send(from, {:result, result})
    {:noreply, result}
  end
end
