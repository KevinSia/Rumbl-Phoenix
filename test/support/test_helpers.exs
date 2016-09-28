defmodule Rumbl.TestHelpers do
  alias Rumbl.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
        name: "Some User",
        # one byte has 8 bit, which is 0 - 255
        # study about binary in Elixir
        # http://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html
        username: "user_#{Base.encode16(:crytpo.rand_bytes(8))}",
        password: "supersecret"
      }, attrs)

      %Rumbl.User{}
      |> Rumbl.User.registration_changeset(changes)
      |> Repo.insert!()
  end

  def insert_video(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:videos, attrs)
    |> Repo.insert!()
  end
end
