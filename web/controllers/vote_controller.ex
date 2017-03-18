defmodule FbLive.VoteController do
  use FbLive.Web, :controller
  require Logger

  @post_id Application.get_env(:fb_live, :post_id)

  def index(conn, _params) do
    render conn, "index.html"
  end

  def verify(conn, %{"hub.challenge" => challenge} = params) do
    text conn, challenge
  end
  def verify(conn, params) do
    render conn, "list.json", %{params: params}
  end

  def receive(conn, %{ "entry" => entries, "object" => "page"} = params) do
    Logger.debug "Matched FB entry"

    entries
    |> Enum.map(fn entry -> Map.get(entry, "changes") end)
    |> Enum.map(fn changes -> Enum.map(changes, &map_change/1) end)

    text conn, "ok"
  end
  def receive(conn, _params), do: text conn, "No match"

  defp map_change(%{"field" => "feed", "value" => value}) do
    Logger.debug "Map reactions"

    change(value)
  end
  
  defp change(%{ 
    "reaction_type" => type, 
    "post_id" => @post_id,
    "verb" => "add",
    "created_time" => created_at,
    "sender_id" => sender_id
  } = value) 
  do
    Logger.debug "Matched reaction #{type}"
    FbLive.Reaction.to(%{
      "type" => type,
      "post_id" => @post_id,
      "action" => "add",
      "created_at" => created_at,
      "sender_id" => sender_id
    })

    value
  end
  defp change(value), do: value 
end
