defmodule Mix.Tasks.Cdk.Test do
  @moduledoc "Emits the synthesized CloudFormation template from the CDK definitions"
  @shortdoc "Executes CDK tests"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Shell.cmd("npm run test", [cd: "./infra/"], fn output -> IO.write(output) end)
  end
end
