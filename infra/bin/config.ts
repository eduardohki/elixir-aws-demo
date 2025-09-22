import { RemovalPolicy } from "aws-cdk-lib";
import { InstanceClass, InstanceSize, InstanceType } from "aws-cdk-lib/aws-ec2";
import type { ElixirFargateStackProps } from "../lib/elixir-fargate-stack";

const EnvName = ["dev", "prod"] as const;
type EnvName = (typeof EnvName)[number];

type GlobalProps = {
	/**
	 * The ID of the AWS Account to deploy to.
	 */
	accountId: string;
	/**
	 * The AWS Region to deploy to.
	 */
	region: string;
	/**
	 * A set of tags to be applied to all deployed resources.
	 */
	tags: Record<string, string>;
};

type StackConfig = ElixirFargateStackProps & GlobalProps;

type EnvConfig = Record<EnvName, StackConfig>;

export const getTargetEnvConfig = (): StackConfig => {
	const envName = process.env.ENVIRONMENT ?? "dev";
	if (EnvName.includes(envName as EnvName))
		return envConfig[envName as EnvName];
	throw new Error(
		`Invalid value for the ENVIRONMENT env var. Available options: ${EnvName}`,
	);
};

const envConfig: EnvConfig = {
	dev: {
		accountId: "000000000000",
		region: "eu-central-1",
		tags: {
			Environment: "dev",
			Owner: "product",
		},
		vpc: {
			maxAzs: 2,
			useSingleNatGateway: true,
		},
		dns: {
			baseDomain: "example.com",
			appDomain: "demo-todo-dev.example.com",
		},
		database: {
			instanceType: InstanceType.of(
				InstanceClass.BURSTABLE4_GRAVITON,
				InstanceSize.MICRO,
			),
			multiAz: false,
			storageSizeInGb: 20,
			maxStorageSizeInGb: 50,
		},
		container: {
			dockerfileDirectoryPath: "../",
			port: 4000,
			cpuUnits: 256,
			memoryLimitMiB: 512,
			healthCheckPath: "/healthz",
		},
		removalPolicy: RemovalPolicy.DESTROY,
	},
	prod: {
		accountId: "111111111111",
		region: "eu-central-1",
		tags: {
			Environment: "prod",
			Owner: "product",
		},
		vpc: {
			maxAzs: 3,
		},
		dns: {
			baseDomain: "example.com",
			appDomain: "demo-todo.example.com",
		},
		database: {
			instanceType: InstanceType.of(InstanceClass.M8G, InstanceSize.MEDIUM),
			multiAz: true,
			storageSizeInGb: 50,
			maxStorageSizeInGb: 200,
		},
		container: {
			dockerfileDirectoryPath: "../",
			port: 4000,
			cpuUnits: 512,
			memoryLimitMiB: 1024,
			healthCheckPath: "/healthz",
		},
		removalPolicy: RemovalPolicy.RETAIN,
	},
};
