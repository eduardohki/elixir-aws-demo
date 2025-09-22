defmodule Mix.Tasks.Cdk.Diff do
  @moduledoc """
  Compares deployed Stack with current CDK definitions

  Requires the default AWS CLI profile to be configured in the Shell you are executing this, _e.g._ via `assume` ([Granted](https://granted.dev/)).
  """
  @shortdoc "Runs `cdk diff`"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Shell.cmd("npm run cdk diff", [cd: "./infra/"], fn output -> IO.write(output) end)
  end
end
