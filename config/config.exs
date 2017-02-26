# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :fb_live,
  ecto_repos: [FbLive.Repo]

# Configures the endpoint
config :fb_live, FbLive.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jRQqXQRWo4ZYQ+jB091kttTFTX/De3+0dV+G3bZ9PJrahy8wDTnGFlzVRnB7Ezv0",
  render_errors: [view: FbLive.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FbLive.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Facebook settings
config :facebook, :appsecret, System.get_env("FB_APP_SECRET")
config :fb_live, :access_token, System.get_env("FB_ACCESS_TOKEN")
config :fb_live, :post_id, System.get_env("FB_POST_ID")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
