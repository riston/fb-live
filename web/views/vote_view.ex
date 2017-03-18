
defmodule FbLive.VoteView do
  use FbLive.Web, :view

  def render("list.json", params) do
    params
    |> IO.inspect
  end
end
