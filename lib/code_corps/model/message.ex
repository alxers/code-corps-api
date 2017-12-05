defmodule CodeCorps.Message do
  @moduledoc """
  A message sent from a project to a user or from a user to a project.
  """

  use CodeCorps.Model
  alias CodeCorps.Message

  @type t :: %__MODULE__{}

  schema "messages" do
    field :body, :string
    field :initiated_by, :string
    field :subject, :string

    belongs_to :author, CodeCorps.User
    belongs_to :project, CodeCorps.Project

    timestamps()
  end

  @doc false
  @spec changeset(Message.t, map) :: Ecto.Changeset.t
  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, [:body, :initiated_by, :subject])
    |> validate_required([:body, :initiated_by])
    |> validate_inclusion(:initiated_by, initiated_by_sources())
    |> maybe_validate_subject()
  end

  # validate subject only if initiated_by "admin"
  @spec maybe_validate_subject(Ecto.Changeset.t) :: Ecto.Changeset.t
  defp maybe_validate_subject(changeset) do
    initiated_by = changeset |> Ecto.Changeset.get_field(:initiated_by)
    changeset |> do_maybe_validate_subject(initiated_by)
  end

  defp do_maybe_validate_subject(changeset, "admin") do
    changeset |> validate_required(:subject)
  end
  defp do_maybe_validate_subject(changeset, _), do: changeset

  @spec initiated_by_sources :: Ecto.Changeset.t
  defp initiated_by_sources do
    ~w{ admin user }
  end
end
