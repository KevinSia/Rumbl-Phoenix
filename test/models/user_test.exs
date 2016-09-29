defmodule Rumbl.UserTest do
  use Rumbl.ModelCase, async: true
  alias Rumbl.User

  @valid_attrs %{name: "some name", username: "some username"}
  @invalid_attrs %{password: "missing name and username"}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset does not accept long usernames" do
    attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
    assert {:username, "should be at most 20 character(s)"} in errors_on(%User{}, attrs)
  end

  test "registration changeset password must be 6 chars long" do
    attrs = Map.put(@valid_attrs, :password, "12345")
    changeset = User.registration_changeset(%User{}, attrs)
    refute changeset.valid?
  end

  test "registraion changeset hashed password if attrs valid" do
    attrs = Map.put(@valid_attrs, :password, "123456")
    changeset = User.registration_changeset(%User{}, attrs)
    %{password: pw, password_hash: hashed_pw} = changeset.changes
    assert changeset.valid?
    assert hashed_pw
    assert Comeonin.Bcrypt.checkpw(pw, hashed_pw)
  end
end
