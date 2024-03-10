defmodule RinhaBackend.Schemas.Entry do
  @moduledoc """
  Represents the client's transactions
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  @required ~w(amount type description client_id)a

  @primary_key false
  schema "entries" do
    field(:amount, :integer)
    field(:type, :string)
    field(:description, :string)
    field(:client_id, :integer)

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(schema \\ %__MODULE__{}, params) do
    params = downcase_type(params)

    schema
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_number(:amount, greater_than: 0)
    |> validate_length(:description, min: 1, max: 10)
    |> validate_inclusion(:type, ~w(d c))
  end

  @spec new(map()) :: {:ok, t()} | {:error, :invalid_args}
  def new(params) do
    params
    |> changeset()
    |> case do
      %Changeset{valid?: true} = changes ->
        {:ok, Changeset.apply_changes(changes)}

      _ ->
        {:error, :invalid_args}
    end
  end

  defp downcase_type(params) do
    type = params["type"] || params[:type] || ""

    Map.put(params, :type, String.downcase(type))
  end
end
