
defmodule FbLive.CommandChannel do
    use Phoenix.Channel

    def join("command:lobby", _message, socket) do
        {:ok, FbLive.MazeConnect.get_state, socket}
    end

    def join("command:" <> _private_room_id, _params, _socket) do
        {:error, %{reason: "Unauthorized"}}
    end

    def handle_in("increment", payload, socket) do
        broadcast! socket, "increment", payload
        {:noreply, socket}
    end
end