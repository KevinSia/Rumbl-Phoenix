defmodule Rumbl.Annotation do
  use Rumbl.Web, :model

  schema "annotations" do
    field :body, :string
    field :at, :integer
    belongs_to :user, Rumbl.User
    belongs_to :video, Rumbl.Video

    timestamps()
  end

  @required_fields ~w(body at)a
  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
