#!/usr/bin/env node
import { App, Tags } from "aws-cdk-lib";
import { ElixirFargateStack } from "../lib/elixir-fargate-stack";
import { getTargetEnvConfig } from "./config";

const config = getTargetEnvConfig();

const app = new App();

new ElixirFargateStack(app, "DemoTodo", {
	env: {
		account: config.accountId,
		region: config.region,
	},
	vpc: config.vpc,
	dns: config.dns,
	database: config.database,
	container: config.container,
	removalPolicy: config.removalPolicy,
});

// apply tags to the all resources in all stacks
Object.entries(config.tags).forEach((tag) => {
	const [key, value] = tag;
	Tags.of(app).add(key, value);
});
