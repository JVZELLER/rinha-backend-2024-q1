defmodule ReleaseTasks do
  @moduledoc """
  Provides functions to create and migrate the database.

  These functions are usually called after a release.
  """

  @app :rinha_backend

  @spec migrate() :: [{:ok, [integer()], Application.app()}]
  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
