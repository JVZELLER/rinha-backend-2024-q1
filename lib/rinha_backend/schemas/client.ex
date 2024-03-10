defmodule RinhaBackend.Schemas.Client do
  @moduledoc """
  Represents the schema we use to store clients' data
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias RinhaBackend.Schemas.Entry

  @type t :: %__MODULE__{}

  @required ~w(balance limit)a

  schema "clients" do
    field(:balance, :integer)
    field(:limit, :integer)

    has_many(:entries, Entry, references: :id)

    timestamps()
  end

  @doc false
  def changeset(schema \\ %__MODULE__{}, params) do
    schema
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
