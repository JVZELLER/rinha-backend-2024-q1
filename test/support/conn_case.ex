defmodule RinhaBackend.ConnCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use RinhaBackend.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL

  using do
    quote do
      use Plug.Test

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import RinhaBackend.ConnCase
      import RinhaBackend.Factory

      alias RinhaBackendWeb.Endpoint
      alias RinhaBackend.Repo
    end
  end

  setup tags do
    :ok = SQL.Sandbox.checkout(RinhaBackend.Repo)

    unless tags[:async] do
      SQL.Sandbox.mode(RinhaBackend.Repo, {:shared, self()})
    end

    :ok
  end
end
