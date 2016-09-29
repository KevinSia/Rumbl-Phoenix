defmodule Rumbl.CategoryTest do
  use Rumbl.ModelCase

  alias Rumbl.Category

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end

  # a test with side effect (inserting into repo)
  test "alphabetical/1 orders by name" do
    for name <- ~w(c a b) do
      Repo.insert!(%Category{name: name})
    end

    query = Category |> Category.alphabetical()
    query = from c in query, select: c.name
    assert Repo.all(query) == ~w(a b c)
  end
end
