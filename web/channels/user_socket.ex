defmodule Rumbl.UserSocket do
  # goes into this module from
  # socket "/socket", Rumbl.UserSocket
  # in lib/rumbl/endpoint.ex
  use Phoenix.Socket

  # 2 weeks
  @max_age 2 * 7 * 24 * 60 * 60

  ## Channels
  # channel "room:*", Rumbl.RoomChannel
  channel "video:*", Rumbl.VideoChannel

  # when client wants to join a channel, they need to provide a topic
  # "video:*" is an example of a topic
  # the socket connection is made by javascript in socket.js

  ## Transports: route events into your Socket
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(%{"token" => token}, socket) do
    # "user socket" is the salt/secret for the token
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @max_age) do
      {:ok, user_id} -> {:ok, assign(socket, :user_id, user_id)}
      {:error, _reason} -> :error
    end
  end

  def connect(_params, _socket) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Rumbl.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end
