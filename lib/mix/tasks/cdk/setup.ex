defmodule Mix.Tasks.Cdk.Setup do
  @moduledoc "Install CDK dependencies via NPM"
  @shortdoc "Runs `npm i` inside the `infra/` folder"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Shell.cmd("npm ci", [cd: "./infra/"], fn output -> IO.write(output) end)
  end
end
