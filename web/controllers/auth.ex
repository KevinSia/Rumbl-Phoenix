defmodule Rumbl.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  # import functions from controller (put_flash & redirect)
  import Phoenix.Controller

  # import the router helpers, but we want to use Rumbl.Auth in our router,
  # so that would lead to a circular dependency between the router and the auth module
  # alias will suffice
  alias Rumbl.Router.Helpers

  # extracting the repo
  # raise an exception if unable to extract
  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  # getting the value for atom 'user_id' and set current_user atom
  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(Rumbl.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    # assign a key-value pair with found user as the value
    |> assign(:current_user, user)
    # puts the pair into the request's session
    |> put_session(:user_id, user.id)
    # It tells Plug to send the session cookie back to the client with a different identifier
    |> configure_session(renew: true)
  end

  def logout(conn) do
    # drops the whole session
    configure_session(conn, drop: true)
    # delete_session(conn, :user_id)
  end

  def login_by_username_and_pass(conn, username, pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Rumbl.User, username: username)
    cond do
      user && checkpw(pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw() # avoid timing attack
        {:error, :not_found, conn}
    end
  end

  # authenticate function must be in arity 2 for it to be able to become a plug
  # this function is meant to be shared across different controllers
  # will be imported through web/web.ex in the controller & router macro
  # controller: for individual actions
  # router: for scoped routes, will not go to controller if user not authenticated
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page.")
      |> redirect(to: Helper.page_path(conn, :index))
      |> halt() # stop any downstream transformations
    end
  end
end
