defmodule CodeCorps.Policy.Message do
  @moduledoc """
  Handles `User` authorization of actions on `Message` records
  """

  import CodeCorps.Policy.Helpers, only: [administered_by?: 2, get_project: 1]

  alias CodeCorps.{Message, User}

  def show?(%User{id: user_id}, %{initiated_by: "user", author_id: author_id})
    when user_id == author_id do
    true
  end
  def show?(%User{} = user, %Message{} = message) do
    message |> get_project() |> administered_by?(user)
  end
  def show?(_, _), do: false

  def create?(%User{id: id}, %{"initiated_by" => "user", "author_id" => author_id}) do
    id == author_id
  end
  def create?(%User{} = user, %{"initiated_by" => "admin", "project_id" => _} = params) do
    params |> get_project() |> administered_by?(user)
  end
  def create?(_, _), do: false
end
