defmodule FbLive.CityController do
  use FbLive.Web, :controller
  require Logger

  plug :put_layout, false

  def index(conn, _params) do
    render conn, "index.html"
  end
end
