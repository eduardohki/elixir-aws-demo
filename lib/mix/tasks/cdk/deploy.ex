defmodule Mix.Tasks.Cdk.Deploy do
  @moduledoc """
  Deploys the current CDK definitions

  Requires the default AWS CLI profile to be configured in the Shell you are executing this, _e.g._ via `assume` ([Granted](https://granted.dev/)).
  """
  @shortdoc "Runs `cdk deploy`"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Shell.cmd(
      "npm run deploy:auto-approve",
      [cd: "./infra/"],
      fn output ->
        IO.write(output)
      end
    )
  end
end

defmodule Mix.Tasks.Cdk.Deploy.Prod do
  @moduledoc """
  Deploys the current CDK definitions to production

  Requires the default AWS CLI profile to be configured in the Shell you are executing this, _e.g._ via `assume` ([Granted](https://granted.dev/)).
  """
  @shortdoc "Runs `cdk deploy`"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Shell.cmd(
      "npm run deploy:auto-approve",
      [cd: "./infra/", env: [{"ENVIRONMENT", "prod"}]],
      fn output ->
        IO.write(output)
      end
    )
  end
end
