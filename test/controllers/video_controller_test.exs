defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase
  alias Rumbl.Video

  # instead of putting user_id directly into session
  # creates a user and add into `conn` directly
  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(build_conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  @valid_attrs %{url: "http://youtu.be", title: "vid", description: "a vid"}
  @invalid_attrs %{title: "invalid"}
  defp video_count(query), do: Repo.one(from v in query, select: count(v.id))

  # Any seeded fixtures in the database will be wiped between test blocks
  test "Authenticating all actions", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      put(conn, video_path(conn, :update, "123", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123"))
      ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  @tag login_as: "a person"
  test "GET :index", %{conn: conn, user: current_user} do
    user_video = insert_video(current_user, title: "A video")
    other_video = insert_video(insert_user(username: "someone else"), title: "Another video")

    conn = get conn, video_path(conn, :index)

    assert html_response(conn, 200) =~ ~r/Listing Videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  @tag login_as: "a person"
  test "POST :create with valid params create the vid and redirects the user", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  end

  @tag login_as: "a person"
  test "POST :create with invalid params", %{conn: conn} do
    count_before = video_count(Video)
    conn = post conn, video_path(conn, :create), video: @invalid_attrs
    assert html_response(conn, 200) =~ "error"
    assert video_count(Video) == count_before
  end

  @tag login_as: "a person"
  test "authorizes access against access by other user", %{conn: conn, user: user_1} do
    video = insert_video(user_1, title: "user 1's vid")
    user_2 = insert_user(username: "user 2")
    # log in as user_2
    conn = assign(conn, :current_user, user_2)

    # access user_1's video
    assert_error_sent :not_found, fn ->
      get conn, video_path(conn, :show, video)
    end

    assert_error_sent :not_found, fn ->
      get conn, video_path(conn, :edit, video)
    end

    assert_error_sent :not_found, fn ->
      put conn, video_path(conn, :update, video, video: @valid_attrs)
    end

    assert_error_sent :not_found, fn ->
      delete conn, video_path(conn, :delete, video)
    end
  end
end
