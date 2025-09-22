# Elixir AWS Demo Todo App

This is an example Elixir application showcasing how it can be deployed to AWS using CDK and ECS Fargate.

## Requirements

- AWS CLI
- AWS CLI profile configured (_e.g._ with `assume` - [Granted](https://granted.dev))
- Node.js LTS
- Docker (or Podman alongside `docker-buildkit` installed)

## Getting Started

- Run `mix setup` to install and setup dependencies
- Run `mix phx.server` to start the Phoenix endpoint (or `iex -S mix phx.server` inside IEx)
- Run `mix cdk.synth` to generate the CloudFormation template from the CDK definitions

See the files under [lib/mix/tasks/cdk](lib/mix/tasks/cdk) for more details on available tasks.

_Note_: You'll need to change the [infra/bin/config.ts](infra/bin/config.ts) file accordingly to be able to deploy this Stack to your own infrastructure.
