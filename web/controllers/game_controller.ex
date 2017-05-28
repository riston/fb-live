defmodule FbLive.GameController do
  use FbLive.Web, :controller
  require Logger

  @post_id Application.get_env(:fb_live, :post_id)

  def verify(conn, %{"hub.challenge" => challenge}) do
    text conn, challenge
  end
  def verify(conn, _params), do: text conn, "Unable to verify"

  def receive(conn, %{ "entry" => entries, "object" => "page"}) do
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
    "verb" => verb,
    "created_time" => created_at,
    "sender_id" => sender_id
  } = value) 
  do
    Logger.debug "Matched reaction #{type}"
    case verb do
        x when x in ["add", "edit"] -> 
            FbLive.Reaction.to(%{
                "type" => type,
                "post_id" => @post_id,
                "action" => "add",
                "created_at" => created_at,
                "sender_id" => sender_id
            })
        value
        _ -> value
    end
  end
  defp change(value), do: value 
end
