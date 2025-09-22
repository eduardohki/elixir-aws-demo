import { type RemovalPolicy, Stack, type StackProps } from "aws-cdk-lib";
import {
	type InstanceType,
	IpProtocol,
	SubnetType,
	Vpc,
} from "aws-cdk-lib/aws-ec2";
import { DockerImageAsset } from "aws-cdk-lib/aws-ecr-assets";
import { ContainerImage, Secret as EcsSecret } from "aws-cdk-lib/aws-ecs";
import { ApplicationLoadBalancedFargateService } from "aws-cdk-lib/aws-ecs-patterns";
import {
	ApplicationProtocol,
	IpAddressType,
} from "aws-cdk-lib/aws-elasticloadbalancingv2";
import {
	CaCertificate,
	Credentials,
	DatabaseInstance,
	DatabaseInstanceEngine,
	DatabaseSecret,
	NetworkType,
	PostgresEngineVersion,
	StorageType,
} from "aws-cdk-lib/aws-rds";
import { HostedZone } from "aws-cdk-lib/aws-route53";
import { type ISecret, Secret } from "aws-cdk-lib/aws-secretsmanager";
import { Database, Provider, Role, Schema } from "cdk-rds-sql";
import type { Construct } from "constructs";

export type ElixirFargateStackProps = StackProps & {
	/** VPC options. */
	vpc: {
		/**
		 * Defines how many Availability Zones the provisioned VPC should have.
		 */
		maxAzs: 2 | 3;
		/**
		 * Defines whether only a single NAT Gateway should be provisioned for the entire VPC,
		 * instead of the default of one per Availability Zone, for cost saving reasons.
		 *
		 * _Important_: don't set this to `true` for production environments, due the risk of losing access to
		 * the Internet in the case of the Availability Zone hosting the NAT Gateway going offline.
		 *
		 * @default false
		 */
		useSingleNatGateway?: boolean;
	};
	/** DNS options. */
	dns: {
		/**
		 * The FQDN of the existing Route53 Hosted Zone to be used for creating the application's DNS entry and TLS certificate.
		 *
		 * @example "example.com"
		 */
		baseDomain: string;
		/**
		 * The FQDN used to be attached to the application's load balancer.
		 * It must contain or match the FQDN provided in `baseDomain`.
		 *
		 * @example "app.example.com" or "example.com"
		 */
		appDomain: string;
	};
	/** Database options. */
	database: {
		/**
		 * The type of the database instance.
		 */
		instanceType: InstanceType;
		/**
		 * Defines whether the database instance should be deployed in a multiple Availability Zone mode.
		 *
		 * Setting it to `false` helps saving costs but should not be done in production environments.
		 *
		 */
		multiAz: boolean;
		/**
		 * The storage size to be allocated to the database.
		 */
		storageSizeInGb: number;
		/**
		 * Upper limit to which RDS can scale the allocated storage automatically.
		 *
		 * @default no database storage autoscaling.
		 */
		maxStorageSizeInGb?: number;
	};
	/** Container options. */
	container: {
		/**
		 * The path to the folder containing the Dockerfile used to build the container image
		 */
		dockerfileDirectoryPath: string;
		/**
		 * The container port to be exposed via the load balancer.
		 */
		port: number;
		/**
		 * The number of cpu units used by the task.
		 *
		 * Valid values, which determines your range of valid values for the memory parameter:
		 *
		 * 256 (.25 vCPU) - Available memory values: 0.5GB, 1GB, 2GB
		 *
		 * 512 (.5 vCPU) - Available memory values: 1GB, 2GB, 3GB, 4GB
		 *
		 * 1024 (1 vCPU) - Available memory values: 2GB, 3GB, 4GB, 5GB, 6GB, 7GB, 8GB
		 *
		 * 2048 (2 vCPU) - Available memory values: Between 4GB and 16GB in 1GB increments
		 *
		 * 4096 (4 vCPU) - Available memory values: Between 8GB and 30GB in 1GB increments
		 *
		 * 8192 (8 vCPU) - Available memory values: Between 16GB and 60GB in 4GB increments
		 *
		 * 16384 (16 vCPU) - Available memory values: Between 32GB and 120GB in 8GB
		 */
		cpuUnits: number;
		/**
		 * The amount (in MiB) of memory used by the task.
		 *
		 * This field is required and you must use one of the following values, which determines your range of valid values for the cpu parameter:
		 *
		 * 512 (0.5 GB), 1024 (1 GB), 2048 (2 GB) - Available cpu values: 256 (.25 vCPU)
		 *
		 * 1024 (1 GB), 2048 (2 GB), 3072 (3 GB), 4096 (4 GB) - Available cpu values: 512 (.5 vCPU)
		 *
		 * 2048 (2 GB), 3072 (3 GB), 4096 (4 GB), 5120 (5 GB), 6144 (6 GB), 7168 (7 GB), 8192 (8 GB) - Available cpu values: 1024 (1 vCPU)
		 *
		 * Between 4096 (4 GB) and 16384 (16 GB) in increments of 1024 (1 GB) - Available cpu values: 2048 (2 vCPU)
		 *
		 * Between 8192 (8 GB) and 30720 (30 GB) in increments of 1024 (1 GB) - Available cpu values: 4096 (4 vCPU)
		 *
		 * Between 16384 (16 GB) and 61440 (60 GB) in increments of 4096 (4 GB) - Available cpu values: 8192 (8 vCPU)
		 *
		 * Between 32768 (32 GB) and 122880 (120 GB) in increments of 8192 (8 GB) - Available cpu values: 16384 (16 vCPU)
		 */
		memoryLimitMiB: number;
		/**
		 * The HTTP path for health check requests.
		 *
		 * @default /
		 */
		healthCheckPath?: string;
	};
	/**
	 * Defines the default removal policy for all applicable resources of this stack.
	 *
	 * Useful for overwriting CloudFormation's default policies when deleting stateful resources on non-production environments.
	 */
	removalPolicy: RemovalPolicy;
};

export class ElixirFargateStack extends Stack {
	constructor(scope: Construct, id: string, props: ElixirFargateStackProps) {
		super(scope, id, props);

		const vpc = new Vpc(this, "Vpc", {
			maxAzs: props.vpc.maxAzs,
			natGateways: props.vpc.useSingleNatGateway ? 1 : undefined,
			ipProtocol: IpProtocol.DUAL_STACK,
		});

		const domain = HostedZone.fromLookup(this, "ApplicationDomain", {
			domainName: props.dns.baseDomain,
		});

		const databaseAdminCredentials = new DatabaseSecret(
			this,
			"DatabaseAdminCredentials",
			{
				secretName: `/${id}/db/credentials/admin`.toLowerCase(),
				username: "postgres",
			},
		);

		const databaseInstance = new DatabaseInstance(this, "DatabaseInstance", {
			vpc,
			instanceType: props.database.instanceType,
			engine: DatabaseInstanceEngine.postgres({
				version: PostgresEngineVersion.VER_17,
			}),
			multiAz: props.database.multiAz,
			credentials: Credentials.fromSecret(databaseAdminCredentials),
			allocatedStorage: props.database.storageSizeInGb,
			maxAllocatedStorage: props.database.maxStorageSizeInGb,
			storageType: StorageType.GP3,
			caCertificate: CaCertificate.RDS_CA_ECC384_G1,
			networkType: NetworkType.DUAL,
			removalPolicy: props.removalPolicy,
		});

		if (!databaseInstance.secret) {
			throw new Error("The database admin credentials are not defined!");
		}

		const databaseApplicationCredentials =
			this.provisionPostgresDatabaseCredentials({
				databaseInstance,
				secretName: `/${id}/db/credentials/application`.toLowerCase(),
				username: "app",
				databaseName: "demo_app",
				schemaName: "public",
			});

		const appSecrets = new Secret(this, "ApplicationSecrets", {
			secretName: `/${id}/application/secrets`.toLowerCase(),
			description: `${id} application secrets`,
			generateSecretString: {
				secretStringTemplate: JSON.stringify({}),
				generateStringKey: "SECRET_KEY_BASE",
				excludeCharacters: " %+~`#$&*()|[]{}:;<>?!'/@\"\\",
				passwordLength: 64,
			},
		});

		const containerImage = new DockerImageAsset(this, "ContainerImage", {
			directory: props.container.dockerfileDirectoryPath,
		});

		const app = new ApplicationLoadBalancedFargateService(this, "App", {
			vpc,
			domainZone: domain,
			domainName: props.dns.appDomain,
			cpu: props.container.cpuUnits,
			memoryLimitMiB: props.container.memoryLimitMiB,
			taskImageOptions: {
				image: ContainerImage.fromDockerImageAsset(containerImage),
				containerPort: props.container.port,
				environment: {
					PHX_HOST: props.dns.appDomain,
					PORT: props.container.port.toString(),
					DATABASE_HOST: databaseInstance.instanceEndpoint.hostname,
					DATABASE_PORT: databaseInstance.instanceEndpoint.port.toString(),
				},
				secrets: {
					DATABASE_USERNAME: EcsSecret.fromSecretsManager(
						databaseApplicationCredentials,
						"username",
					),
					DATABASE_PASSWORD: EcsSecret.fromSecretsManager(
						databaseApplicationCredentials,
						"password",
					),
					DATABASE_NAME: EcsSecret.fromSecretsManager(
						databaseApplicationCredentials,
						"dbname",
					),
					SECRET_KEY_BASE: EcsSecret.fromSecretsManager(
						appSecrets,
						"SECRET_KEY_BASE",
					),
				},
			},
			ipAddressType: IpAddressType.DUAL_STACK,
			protocol: ApplicationProtocol.HTTPS,
			redirectHTTP: true,
			minHealthyPercent: 100,
			circuitBreaker: {
				enable: true,
				rollback: true,
			},
			enableExecuteCommand: true,
		});

		app.targetGroup.configureHealthCheck({
			path: props.container.healthCheckPath,
		});

		databaseInstance.connections.allowDefaultPortFrom(
			app.service,
			"Allow Postgres access from the application",
		);

		const scalableTarget = app.service.autoScaleTaskCount({
			minCapacity: 1,
			maxCapacity: 5,
		});

		scalableTarget.scaleOnCpuUtilization("CpuScaling", {
			targetUtilizationPercent: 50,
		});

		scalableTarget.scaleOnMemoryUtilization("MemoryScaling", {
			targetUtilizationPercent: 50,
		});
	}

	private provisionPostgresDatabaseCredentials = (
		props: PostgresDatabaseCredentials,
	): ISecret => {
		const databaseProvider = new Provider(this, "DatabaseProvider", {
			vpc: props.databaseInstance.vpc,
			vpcSubnets: {
				subnetType: SubnetType.PRIVATE_WITH_EGRESS,
			},
			cluster: props.databaseInstance,
			secret: props.databaseInstance.secret,
			functionProps: {
				ipv6AllowedForDualStack: true,
				allowAllIpv6Outbound: true,
			},
		});

		const postgresDatabase = new Database(this, "ApplicationDatabase", {
			provider: databaseProvider,
			databaseName: props.databaseName,
		});

		const databaseApplicationCredentials = new Role(
			this,
			"DatabaseApplicationCredentials",
			{
				secretName: props.secretName,
				provider: databaseProvider,
				roleName: props.username,
				database: postgresDatabase,
			},
		);

		new Schema(this, "DatabaseSchema", {
			provider: databaseProvider,
			database: postgresDatabase,
			schemaName: props.schemaName,
			role: databaseApplicationCredentials,
		});

		if (!databaseApplicationCredentials.secret) {
			throw new Error("The database application credentials are not defined!");
		}

		return databaseApplicationCredentials.secret;
	};
}

type PostgresDatabaseCredentials = {
	databaseInstance: DatabaseInstance;
	secretName: string;
	username: string;
	databaseName: string;
	schemaName: string;
};
