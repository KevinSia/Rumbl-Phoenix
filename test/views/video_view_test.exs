defmodule Rumbl.VideoViewTest do
  use Rumbl.ConnCase, async: true
  alias Rumbl.Video
  import Phoenix.View

  test "render index.html", %{conn: conn} do
    videos = [
      %Video{id: "1", title: "woof"},
      %Video{id: "2", title: "meow"}
    ]

    # remember, templates are just functions inside view
    content = render_to_string(Rumbl.VideoView, "index.html", conn: conn, videos: videos)

    assert String.contains?(content, "Listing Videos")
    for vid <- videos do
      assert String.contains?(content, vid.title)
    end
  end

  test "render new.html", %{conn: conn} do
    changeset = Video.changeset(%Video{})
    categories = [{"cats", 123}]

    content = render_to_string(Rumbl.VideoView, "new.html", conn: conn, changeset: changeset, categories: categories)

    assert String.contains?(content, "New video")
  end
end
