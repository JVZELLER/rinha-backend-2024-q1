defmodule RinhaBackendWeb.JSONView do
  @moduledoc """
  Defines the JSON view for clients resources.
  """

  def render(:show, result) do
    %{
      limite: result[:limit] || result["limit"],
      saldo: result[:balance] || result["balance"]
    }
    |> Jason.encode!()
  end
end
