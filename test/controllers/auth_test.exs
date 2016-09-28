defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth
  alias Rumbl.Repo

  setup %{conn: conn} do
    conn =
      conn
      # goes through the :browser pipeline, to avoid errors like
      # "flash not fetched" or "session not fetched"
      |> bypass_through(Rumbl.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Rumbl.User{})
      |> Auth.authenticate_user([])
    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%Rumbl.User{id: 123}) # mocked user
      |> send_resp(:ok, "") # sends the response back to client

    # start another request to check if session[:user_id] is added
    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123) # mocks an user session
      |> Auth.logout
      |> send_resp(:ok, "") # sends the response back to client

    # start another request to check if session[:user_id] is gone
    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call sets a current_user into assigns with user_id found in session", %{conn: conn} do
    user = insert_user(username: "sample user")
    call_conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)

    assert call_conn.assigns.current_user.id == user.id
  end

  test "call with no session set current_user in assigns to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end

  test "login with username and password", %{conn: conn} do
    user = insert_user(username: "someone", password: "123456")
    {:ok, conn} = Auth.login_by_username_and_pass(conn, "someone", "123456", repo: Repo)
    assert conn.assigns.current_user.username == user.username
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _conn} = Auth.login_by_username_and_pass(conn, "no one", "123456", repo: Repo)
  end

  test "login with wrong password", %{conn: conn} do
    _ = insert_user(username: "someone", password: "complicated")
    assert {:error, :unauthorized, _conn} =
      Auth.login_by_username_and_pass(conn, "someone", "forget", repo: Repo)
  end
end
