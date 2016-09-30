defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel

  # controller receive requests
  # channel receive events
  # channel will receive message containing an event name
  # and also a payload of arbitrary data

  # {:ok, socket} to allow a socket connection
  # {:error, socket} to deny one
  def join("video:" <> video_id, _params, socket) do
    # send_interval(interval, message)
    # :timer.send_interval(5_000, :ping)
    video_id = String.to_integer(video_id)
    video = Repo.get!(Rumbl.Video, video_id)

    query = from a in assoc(video, :annotations),
      order_by: [desc: a.at, desc: a.id],
      limit: 100
    query = from a in subquery(query), order_by: [asc: a.at, asc: a.id], preload: [:user]

    annotations = Repo.all query
    resp = %{annotations: Phoenix.View.render_many(annotations, Rumbl.AnnotationView, "annotation.json")}

    {:ok, resp, assign(socket, :video_id, video_id)}
  end

  # invoked whenever an Elixir message reaches the channel (in this case, the `:ping` message)
  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    # push the event back only to the client
    push socket, "ping", %{count: count}

    {:noreply, assign(socket, :count, count + 1)}
  end

  # handle_in functions will handle all incoming messages (not just Elixir messages) to a channel
  # that is pushed directly from remote client
  def handle_in(event, params, socket) do
    # socket.assigns.user_id is gotten from connect function in user_socket.ex
    user = Repo.get(Rumbl.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    # push this event to all sockets with same topic
    # payload must be controlled!
    # just like strong_params in Rails
    changeset =
      user
      |> build_assoc(:annotations, video_id: socket.assigns.video_id)
      |> Rumbl.Annotation.changeset(params)

    case Repo.insert(changeset) do
      {:ok, annotation} ->
        broadcast! socket, "new_annotation", %{
          id: annotation.id,
          user: Rumbl.UserView.render("user.json", %{user: user}),
          body: annotation.body,
          at: annotation.at
        }
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{error: changeset}}, socket}
    end
  end
end
