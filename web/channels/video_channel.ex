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
    {:ok, socket}
    # {:ok, assign(socket, :video_id, String.to_integer(video_id))}
  end

  # invoked whenever an Elixir message reaches the channel (in this case, the `:ping` message)
  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    # push the event back only to the client
    push socket, "ping", %{count: count}

    {:noreply, assign(socket, :count, count + 1)}
  end

  # This function will handle all incoming messages (not just Elixir messages) to a channel
  # that is pushed directly from remote client
  def handle_in("new_annotation", params, socket) do
    # push this event to all sockets with same topic
    broadcast! socket, "new_annotation", %{
      user: %{username: "Kevin"},
      body: params["body"],
      at: params["at"]
    }

    {:reply, :ok, socket}
  end
end
