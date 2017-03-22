# FbLive

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Would you prefer to live in the city or in the countryside?

Placeholder images from:

  - [City](https://pixabay.com/en/hong-kong-china-night-cityscape-1081704/)
  - [Country](https://pixabay.com/en/squantz-pond-connecticut-landscape-209864/)

FB post:
 - Title:  Would you prefer to live in the City or in the Countryside?
 - Description: Do give vote for the "city" like following post or "love" for countryside. #city #country #poll

```
curl -H "Content-Type: application/json" -X POST  "https://graph.facebook.com/v2.6/${FB_PAGE_ID}/live_videos?access_token=${FB_ACCESS_TOKEN}"
```

## Setup the Chromium window

Use separate browser window

```chromium --app=http://localhost:4000/city --window-position=600,600 --incognito```

To make sure the window size is set properly use X11 tool:

```xdotool search --name "City" windowsize 1280 720```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
