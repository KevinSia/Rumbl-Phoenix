defmodule Rumbl.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
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
    |> assign(:current_user, user)
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
end
