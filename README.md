# VitePhoenix

An experimental light-weight module to help with integrating Vite into your Phoenix project and watching for any code change in Vite's side.

- [Background](#background)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Setup steps](#setup-steps)
- [Limitations](#limitations)
- [See also](#see-also)

## Background

Starting from Phoenix 1.6, [esbuild](https://esbuild.github.io/) is used to bundle JavaScript files and other assets instead of webpack. On the other hand, the latest version of Vue 3 recommends using [Vite](https://vitejs.dev/) for building. Vite also supports other templates such as [Lit](https://lit.dev/), [React](https://reactjs.org/), [Preact](https://preactjs.com/), and [Svelte](https://svelte.dev/), etc. Since during development, Phoenix's esbuild will watch for changes inside the assets folder and automatically re-bundles, and that it doesn't support `*.vue` files, `*.svelte` files, etc. directly, without writing a custom build script, it's relatively difficult to integrate Vite into a Phoenix project. Therefore, this tiny module serves to make such process a little bit easier.

With correct setup, VitePhoenix will automatically start watching for changes in your Vite project when you execute `mix phx.server`. It will rebuild your files and put them inside the `priv/static` folder in your Phoenix project.

## Prerequisites
Unlike the [esbuild module](https://github.com/phoenixframework/esbuild) that comes with Phoenix 1.6+, VitePhoenix does **NOT** install [Node.js](https://nodejs.org/en/) for you. Since it runs `npx` for you, you will need to install Node.js before using VitePhoenix.

## Installation

Adding `vite_phoenix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vite_phoenix, "~> 0.1.2"}
  ]
end
```

Then run `mix deps.get`.

## Setup steps

VitePhoenix basically delegates all JavaScript stuffs to Vite, so in order to make it work, there are a few steps that need to be configured.

1. After creating the project folder with `mix phx.new`, navigate to `assets/js` folder under your project, and run either
```
npm create vue@latest
```
to bootstrap your Vue 3 + Vite project, or
```
npm create vite@latest <your-vite-project-name>
```
and select available templates to bootstrap your project.

2. Install VitePhoenix through the steps in [Installation](#installation).

3. In your `config/config.exs`, configure the project name for VitePhoenix. **Your project name here has to match the name you specify when running either `npm create vue@latest` or `npm create vite@latest`**
```elixir
config :vite_phoenix,
  project_name: "<your-vite-project-name>"
```

4. In your `config/dev.exs`, comment out or remove esbuild watcher for your Phoenix project, and add watcher for VitePhoenix.
```elixir
config :my_phoenix, MyPhoenix,
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    # esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    vite_phoenix: {VitePhoenix, :run, [:default, ~w(--sourcemap --watch --emptyOutDir)]}
  ]
```

5. By default, Vite will build everything under your Vite project folder and create a single `index.html`. In order to make use of such `index.html` built by Vite, you would need to change your `PageController` that comes with any new Phoenix project, or any controller that serves as the entry point of your Phoenix project to send `index.html` instead.
```elixir
defmodule MyPhoenixWeb.PageController do
  use MyPhoenixWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_header("Content-Type", "text/html; charset=utf-8")
    |> send_file(200, Application.app_dir(:my_phoenix, "priv/static/index.html"))
  end
end
```

6. (Optional) Delete `templates/page/index.html.heex` and other files under `templates/layout`.

7. (Optional) Delete esbuild-related lines per [Phoenix's guide to remove esbuild](https://hexdocs.pm/phoenix/asset_management.html#removing-esbuild).

8. (Optional) If you're also using vue-router and other routers for SPAs, you would also need to configure your `router.ex` to delegate non-Phoenix routes to your JavaScript router by adding a catch-all route. **Note that the order of routes matters in `router.ex`.**

```elixir
  scope "/api", MyPhoenixWeb do
    pipe_through :browser

    get "/some_api", SomeApiController, :some_action
  end

  scope "/", MyPhoenixWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end
```

9. (Optional) Add files not included in the static path in your `endpoint.ex`

```elixir
  plug Plug.Static,
    at: "/",
    from: :my_phoenix,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt vite.svg)
```

10. Run `mix phx.server` and visit [http://localhost:4000](http://localhost:4000) to see your JavaScript/TypeScript SPA powered by Vite.

## Limitations

Because VitePhoenix basically delegates everything JavaScript/TypeScript to Vite, and doesn't use Phoenix's templates, it neither benefits from Phoenix's hot reload nor Vite's HMR. Even though Vite does rebuilds and puts latest files into `priv/static` when anything is changed inside your Vite project, currently users have to refresh to see the latest result.

## See also
- [Phoenix Framework](https://www.phoenixframework.org/)
- [Phoenix's esbuild module](https://github.com/phoenixframework/esbuild)
- [Vite](https://vitejs.dev/)
- [Elixir](https://elixir-lang.org/)
- [esbuild](https://esbuild.github.io/)
- [Node.js](https://nodejs.org/en/)