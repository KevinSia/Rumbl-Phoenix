defmodule Rumbl.UserRepoTest do
  # contain test cases against codes with side effects (making changes to outside world)
  # such as inserting into Repo
  use Rumbl.ModelCase
  alias Rumbl.User

  @valid_attrs %{name: "some name", username: "some username"}

  test "converts db unique constraint to repo error" do
    insert_user(username: "some username")
    changeset = User.changeset(%User{}, @valid_attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:username, {"has already been taken", []}} in changeset.errors
  end
end
