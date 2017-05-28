
defmodule FbLive.Reaction do
    require Logger
    use GenServer

    @summary_check_time 6000
    @channel_name "command:lobby"
    @avatar_placeholder_url "http://lorempixel.com/50/50"

    def start_link(default) do
        GenServer.start_link(__MODULE__, default, name: :reaction)
    end

    def init(state) do
        # Disable the reaction check
        # schedule_work()
        {:ok, state}
    end

    def like do
        GenServer.cast(:reaction, {:like, %{}})
    end

    def to(value) do
        GenServer.cast(:reaction, {:reaction, value})
    end

    def avatar_lookup(user_id) do
        GenServer.cast(:reaction, {:avatar_lookup, user_id}) 
    end


    def handle_info(:check, state) do
        Logger.debug "Call regular job"
        schedule_work()
        {:noreply, state}
    end

    def handle_cast({:like, _item}, state) do
        Logger.info "Like added"
        FbLive.Endpoint.broadcast! @channel_name, "increment", %{}
        {:noreply, state}
    end

    def handle_cast({:reaction, value}, state) do
        Logger.info "Reaction handled"
        %{ "type" => type } = value

        direction = case type do
            "like" -> :s
            "love" -> :e
            "haha" -> :n
            "wow" -> :w
            _ -> :n
        end

        FbLive.MazeConnect.make_move(direction)

        # %{ "sender_id" => fb_user_id } = value
        # avatar_lookup(fb_user_id)

        {:noreply, state}
    end

    def handle_cast({:avatar_lookup, user_id}, state) do
        Logger.info "FB avatar lookup"
        token = Application.get_env(:fb_live, :access_token)

        avatar_url = case Facebook.picture(user_id, "small", token) do
            {:json, %{"data" => %{ "url" => url}}} -> url
            _ -> @avatar_placeholder_url
        end

        FbLive.Endpoint.broadcast! @channel_name, "avatar", %{
            "user_id": user_id,
            "url": avatar_url
        }

        {:noreply, state}
    end 


    def handle_cast(request, state) do
        super(request, state)
    end

    defp schedule_work() do
        token = Application.get_env(:fb_live, :access_token)
        post_id = Application.get_env(:fb_live, :post_id)

        object_count = Facebook.objectCountAll(post_id, token)
        FbLive.Endpoint.broadcast! @channel_name, "summary", object_count

        Process.send_after(self(), :check, @summary_check_time)
    end
end