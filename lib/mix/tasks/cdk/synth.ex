defmodule Mix.Tasks.Cdk.Synth do
  @moduledoc "Emits the synthesized CloudFormation template from the CDK definitions"
  @shortdoc "Runs `cdk synth`"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Shell.cmd("npm run cdk synth", [cd: "./infra/"], fn output -> IO.write(output) end)
  end
end
