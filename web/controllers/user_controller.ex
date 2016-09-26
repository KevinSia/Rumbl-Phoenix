defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  # only alias needed module
  alias Rumbl.User

  plug :authenticate when action in [:index, :show]
  plug :authorize when action in [:edit, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Rumbl.Auth.login(user)
        |> put_flash(:info, "Welcome to Rumbl, #{user.name}")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    changeset = User.changeset(Repo.get(User, id))
    render conn, "edit.html", changeset: changeset
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get(User, id)
    changeset = case user_params do
        %{"password" => ""} -> User.changeset(user, user_params)
        _ -> User.registration_changeset(user, user_params)
    end
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Updated!")
        |> redirect(to: user_path(conn, :show, user.id))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset
    end
  end

  defp authorize(conn, _) do
    current_user = conn.assigns.current_user
    if current_user && current_user == Repo.get(User, conn.params["id"]) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to access that page.")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

  # authenticate function must be in arity 2 for it to be able to plug
  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page.")
      |> redirect(to: page_path(conn, :index))
      |> halt() # stop any downstream transformations
    end
  end
end
