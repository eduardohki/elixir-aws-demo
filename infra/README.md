# Infra

This is a CDK TypeScript codebase defining the infrastructure to deploy this application on AWS.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

## Requirements

- AWS CLI
- AWS CLI profile configured (_e.g._ with `assume` - [Granted](https://granted.dev))
- Node.js LTS
- Docker (or Podman alongside `docker-buildkit` installed)

## Useful commands

* `npm run build`   compile typescript to js
* `npm run watch`   watch for changes and compile
* `npm run test`    perform the jest unit tests
* `npx cdk deploy`  deploy this stack to your default AWS account/region
* `npx cdk diff`    compare deployed stack with current state
* `npx cdk synth`   emits the synthesized CloudFormation template
