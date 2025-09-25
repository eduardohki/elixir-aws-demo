# Elixir AWS Demo Todo App

This is an example Elixir application showcasing how it can be deployed to AWS using CDK and ECS Fargate.

**Resources deployed via CDK:**

- Container Image
- VPC
- ECS Cluster + Service + Task Definition + Basic Auto Scaling Rules
- RDS PostgreSQL Instance
- PostgreSQL Database, Schema and User/Role for the Application
- Secrets for Admin and Application Database Credentials
- DNS Records (requiring a pre-existing Route53 Hosted Zone)
- Application Load Balancer with TLS Certificate

**What it doesn't include:**

- Support for Distributed Erlang (EPMD + AWS Cloud Map for Service Discovery)
- Advanced monitoring with CloudWatch Container Insights and X-Ray Tracing
- Dedicated KMS Keys (CMK) for encrypting Secrets, Logs and RDS Databases
- Infra-level testing (_e.g._ if all required env vars are present in CDK)

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
