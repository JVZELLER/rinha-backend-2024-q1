defmodule RinhaBackend.Schemas.Client do
  @moduledoc """
  Represents the schema we use to store clients' data
  """
  defstruct ~w(id balance limit inserted_at updated_at)a

  @type t :: %__MODULE__{
          id: integer(),
          balance: integer(),
          limit: integer(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  # TODO: validate args and return {:error, :invalid_args}
  # in case of error
  @spec new(map()) :: t()
  def new(params) do
    struct(__MODULE__, params)
  end
end
