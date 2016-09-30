defmodule Rumbl.Video do
  use Rumbl.Web, :model

  # custom type generated in lib/rumbl
  # tell Ecto to use our custom type for the id field
  # must come before schema definition and after Rumbl.Web (to load the module)
  @primary_key {:id, Rumbl.Permalink, autogenerate: true}

  schema "videos" do
    field :url, :string
    field :title, :string
    field :description, :string
    field :slug, :string
    has_many :annotations, Rumbl.Annotation
    belongs_to :user, Rumbl.User
    belongs_to :category, Rumbl.Category

    timestamps
  end

  @required_fields ~w(url title description)a
  @optional_fields ~w(category_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> slugify_title()
    |> validate_required(@required_fields)
    |> assoc_constraint(:category)
  end

  # create a slug to replace numerical id in URLs
  defp slugify_title(changeset) do
    # if theres any change to the title, update the slug with the new title
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end

  # Elixir protocol to achieve polymorphism http://elixir-lang.org/getting-started/protocols.html
  # Eg.
  # defprotocol Blank do
  #   @doc "Returns true if data is considered blank/empty"
  #   def blank?(data)
  # end
  #
  # defimpl Blank, for: Integer do
  #   def blank?(_), do: false
  # end

  # defimpl Blank, for: List do
  #   def blank?([]), do: true
  #   def blank?(_),  do: false
  # end
  #
  # Blank.blank?([]) => true
  # Blank.blank?(0) => false
  #
  # Phoenix.Param is a protocol with a to_param method that
  # takes out the id from a struct by default to construct the URL
  defimpl Phoenix.Param, for: Rumbl.Video do
    def to_param(%{slug: slug, id: id}) do
      "#{id}-#{slug}"
    end
  end
end
