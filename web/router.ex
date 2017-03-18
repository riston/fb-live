defmodule FbLive.Router do
  use FbLive.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FbLive do
    pipe_through :browser # Use the default browser stack

    get "/", VoteController, :index
    get "/animal", AnimalController, :index
    get "/hand", HandController, :index
    get "/city", CityController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", FbLive do
    pipe_through :api
    
    get "/posts", VoteController, :verify
    post "/posts", VoteController, :receive
  end
end
