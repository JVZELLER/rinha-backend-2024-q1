defmodule RinhaBackend.Commands.CreateEntry do
  @moduledoc """
  Command for creating an entry for a given client.
  """
  alias RinhaBackend.Repo
  alias RinhaBackend.Schemas.Entry

  @spec execute(integer(), Entry.t()) :: {:ok, map()} | :error
  def execute(client_id, entry) do
    {:ok, %{}}
  end
end
