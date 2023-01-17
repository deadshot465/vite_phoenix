defmodule VitePhoenix do
  @default_config %{
    default: [
      args: ~w(vite build --outDir=../../../priv/static --target=es2017),
      cd: Path.expand("../../../assets/js/$PROJECT_NAME", __DIR__)
    ]
  }

  @moduledoc """
  An experimental light-weight module to help with integrating [Vite](https://vitejs.dev/) into your Phoenix project and watching for any code change in Vite's side.

  This module is basically a simplified version of the [esbuild](https://github.com/phoenixframework/esbuild) module that comes with Phoenix framework.

  ## Profiles

  To simplify the usage, while vite_phoenix retains the ability to let user define multiple profiles, it also comes with a default config hard-coded inside the module, so that users won't need to provide the whole profile in their config.exs.

  ## Project name

  That being said, in order to make it work with arbitrary project names set up by Vite during `npm create vite@latest`, users still need to define the project name in `config.exs` that matches the folder name under `assets/js`. The config should look like this:
  ```elixir
  config :vite_phoenix, project_name: "my-vite-project"
  ```
  """

  use Application
  require Logger

  @doc false
  def start(_, _) do
    unless Application.get_env(:vite_phoenix, :project_name) do
      Logger.error("""
      Project name is not configured for vite_phoenix. Please set it in your config files:

          config :vite_phoenix, project_name: "my-vite-project"
      """)
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  @spec config_for(atom) :: Keyword.t()
  def config_for(profile) when is_atom(profile) do
    project_name =
      Application.get_env(:vite_phoenix, :project_name) ||
        raise ArgumentError,
              "You need to at least set the project_name environment variable in your config.exs!"

    config = Application.get_env(:vite_phoenix, profile) || @default_config[:default]
    Keyword.put(config, :cd, String.replace(config[:cd], "$PROJECT_NAME", project_name))
  end

  @spec run(atom, [binary]) :: non_neg_integer
  def run(profile, extra_args) when is_atom(profile) and is_list(extra_args) do
    config = config_for(profile)
    args = config[:args] || []

    if args == [] and extra_args == [] do
      raise "no arguments passed to vite_phoenix"
    end

    opts = [
      cd: config[:cd] || File.cwd!(),
      env: config[:env] || %{},
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    System.cmd("npx", args ++ extra_args, opts)
    |> elem(1)
  end
end
