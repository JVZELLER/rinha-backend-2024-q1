defmodule RinhaBackend.Repo.Migrations.CreateEntriesTable do
  use Ecto.Migration

  def change do
    create table("entries") do
      add(:amount, :bigint)
      add(:type, :string)
      add(:description, :string)

      add(:client_id, references(:clients))

      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    :entries
    |> index(~w(client_id inserted_at)a)
    # |> index(:client_id)
    |> create_if_not_exists()
  end
end
