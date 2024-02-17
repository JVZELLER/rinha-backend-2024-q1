defmodule RinhaBackend.Schemas.Entry do
  @moduledoc """
  Represents the client's transactions
  """
  defstruct ~w(id amount type description client_id inserted_at)a

  defguard valid_type(t) when t in ~w(c d C D)
  defguard valid_description(description) when length(description) <= 10 and description != ""

  @type t :: %__MODULE__{
          id: integer(),
          amount: integer(),
          type: String.t(),
          description: String.t(),
          client_id: integer(),
          inserted_at: NaiveDateTime.t()
        }

  @spec new(map()) :: t() | {:error, :invalid_args}
  def new(%{amount: amount, type: type, description: desc, client_id: client_id} = params)
      when is_integer(amount) and
             valid_type(type) and
             valid_description(desc) and
             is_integer(client_id) do
    struct(__MODULE__, params)
  end

  def new(_invalid), do: {:error, :invalid_args}
end
