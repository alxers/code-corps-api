defmodule CodeCorps.Messages do
  @moduledoc ~S"""
  """

  alias CodeCorps.{Message, Repo}
  alias Ecto.{Changeset}

  @doc ~S"""
  Creates a `CodeCorps.Message` from a set of parameters.
  """
  @spec create(map) :: {:ok, Message.t} | {:error, Changeset.t}
  def create(%{} = params) do
    %Message{}
    |> Message.changeset(params)
    |> Repo.insert()
  end
end
