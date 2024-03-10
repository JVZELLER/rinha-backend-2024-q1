defmodule RinhaBackend.GenServers.BackPressure do
  @moduledoc false

  use GenServer

  alias RinhaBackend.ClientRunner

  @initial_state %{count: 0, batch: []}

  alias RinhaBackend.Commands.CreateEntry

  require Logger

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args) do
    {:ok, id} = Keyword.fetch(args, :id)

    GenServer.start_link(__MODULE__, args, name: :"client_#{id}", restart: :transient)
  end

  @impl true
  def init(_init_arg) do
    schedule_work()

    {:ok, @initial_state}
  end

  ############
  ## Client ##
  ############
  @spec execute(non_neg_integer(), Entry.t()) ::
          {:ok, map()}
          | {:error, :client_not_found}
          | {:error, :entry_amount_exceeds_client_limit}
          | {:error, :timeout}
          | {:error, term()}
  def execute(client_id, entry) do
    client_id
    |> enqueue(self(), entry)
    |> case do
      :ok ->
        receive do
          {:result, value} ->
            value
        after
          timeout() ->
            {:error, :timeout}
        end

      error ->
        Logger.error("Unexpected error during enqueue: #{inspect(error)}")
        {:error, error}
    end
  end

  defp enqueue(client_id, from, payload) do
    {:ok, executor_pid} = start_client_server(client_id)

    # GenServer.cast(executor_pid, {:enqueue, {from, payload}})
    GenServer.call(executor_pid, {:enqueue, {from, payload}})
  end

  defp start_client_server(client_id) do
    :"client_#{client_id}"
    |> GenServer.whereis()
    |> case do
      nil -> DynamicSupervisor.start_child(ClientRunner, {__MODULE__, [id: client_id]})
      pid -> {:ok, pid}
    end
    |> case do
      {:ok, _pid} = result ->
        result

      {:error, {:already_started, pid}} ->
        {:ok, pid}
    end
  end

  ############
  ## Server ##
  ############
  @impl true
  def handle_call({:enqueue, message}, _from, %{count: count, batch: batch} = state) do
    if count == max_concurrency() - 1 do
      process_batch([message | batch])

      {:reply, :ok, @initial_state}
    else
      {:reply, :ok, %{state | count: count + 1, batch: [message | batch]}}
    end
  end

  @impl true
  def handle_info(:dispatch, %{count: 0}) do
    schedule_work()

    {:noreply, @initial_state}
  end

  @impl true
  def handle_info(:dispatch, %{batch: batch}) do
    schedule_work()

    process_batch(batch)

    {:noreply, @initial_state}
  end

  defp process_batch(batch) do
    batch
    |> Enum.reverse()
    |> Enum.map(fn {from, payload} ->
      Task.async(fn ->
        result = CreateEntry.execute(payload)

        send(from, {:result, result})
      end)
    end)
    |> Task.await_many()
  end

  defp schedule_work do
    Process.send_after(self(), :dispatch, dispatch_timeout())
  end

  def max_concurrency,
    do:
      :rinha_backend |> Application.fetch_env!(:back_pressure) |> Keyword.fetch!(:max_concurrency)

  def timeout,
    do: :rinha_backend |> Application.fetch_env!(:back_pressure) |> Keyword.fetch!(:timeout_in_ms)

  def dispatch_timeout,
    do:
      :rinha_backend
      |> Application.fetch_env!(:back_pressure)
      |> Keyword.fetch!(:dispatch_timeout_in_ms)
end
