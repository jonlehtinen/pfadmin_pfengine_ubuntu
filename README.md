# TR-AWS-PINGFEDERATE
By:
- Jon Lehtinen
- Sean Farrell
- Alyssa Kelber

This repository contains the CloudFormation template, DockerFile, and python script, that will populate a unified, global, multi-region, containerized, PingFederate instance running on ECS.

The dockerfile references some files from PingFederate which are not included in this repo, as well as some additional third-party binaries. Any additional modifications you wish to do to your instances should also be accounted for in your own repos, with the files placed in their same paths as found in a running PingFederate server.

This repository makes reference to something called the Asset Insight ID (AAID). This number is like a configuration item, or asset identifier. When used in this repository, it ensures that each environment (dev, qa, prod) are easy to keep separate. It is also critical for most of the naming conventions in the CloudFormation script, so it is recommended you define your environment's AAID's before you begin.

As maintained in this repository, you will need the following files in the following paths (files can be updated with newer versions):

/tr-aws-pingfederate/PingFederate/docker-build-files
- `pingfederate-9.2.0.zip`
- `openjdk-11.0.1_linux-x64_bin.tar.gz`

/tr-aws-pingfederate/PingFederate/docker-build-files/pingfederate/server/default/conf
- `pingfederate.lic`
- `tcp.xml` (pull from PingFederate)

/tr-aws-pingfederate/PingFederate/docker-build-files/pingfederate/server/default/conf/META-INF
- `hivemodule.xml` (pull from PingFederate)

/tr-aws-pingfederate/PingFederate/docker-build-files/pingfederate/server/default/lib
- `postgresql-42.2.2.jar`

/tr-aws-pingfederate/PingFederate/docker-build-files/pingfederate/server/default/data/config-store
- `org.sourceid.oauth20.domain.ClientManagerJdbcImpl.xml` (pull from PingFederate)
- `org.sourceid.oauth20.token.AccessGrantManagerJdbcImpl.xml` (pull from PingFederate)

## PingFederate & Dockerfile Preliminary Tasks

Edit `hivemanager.xml` in /tr-aws-pingfederate/PingFederate/docker-build-files/pingfederate/server/default/conf/META-INF to use the RDS instance for client and grant storage. Set **<service-point id="ClientManager" interface="org.sourceid.oauth20.domain.ClientManager">** to use the construct class of "**org.sourceid.oauth20.domain.ClientManagerJdbcImpl**" and set **<service-point id="AccessGrantManager" interface="com.pingidentity.sdk.accessgrant.AccessGrantManager">** to "**org.sourceid.oauth20.token.AccessGrantManagerJdbcImpl**".

Edit the `org.sourceid.oauth20.domain.ClientManagerJdbcImpl.xml`in /tr-aws-pingfederate/PingFederate/docker-build-files/pingfederate/server/default/data/config-store and replace the default value of **<c:item name="PingFederateDSJNDIName">PFDefaultDS</c:item>** to **<c:item name="PingFederateDSJNDIName">RDSSTORE</c:item>**.

Edit the `org.sourceid.oauth20.token.AccessGrantManagerJdbcImpl.xml`in /tr-aws-pingfederate/PingFederate/docker-build-files/pingfederate/server/default/data/config-store and replace the default value of **<c:item name="PingFederateDSJNDIName">PFDefaultDS</c:item>** to **<c:item name="PingFederateDSJNDIName">RDSSTORE</c:item>**.

Edit `tcp.xml` in /tr-aws-pingfederate/PingFederate/docker-build-files/pingfederate/server/default/conf. Comment out the TCPPING section, and uncomment the AWSPING section. Update the regions and tag sections in AWSPING to look like this:
- regions="us-east-1,eu-west-1,ap-southeast-1"
- tags="AAID"

## AWS Environment & CloudFormation Template Preliminary Tasks

### Items to be manually created
The CloudFormation template assumes there are already three peered VPCs in three regions in the environment, with three private and public subnets in each. If VPCs, subnets, NAT gateways, or any other assumed infrastructure is not in the environment, than that needs to be added to the CloudFormation template, the CloudFormation template adjusted to account for the AWS environment it will run in, those items or built in the AWS environment before running the template for each region. This template could likely be enhanced to automate the creation of these missing components.

### TLS Certificate
Upload a multi-SAN certificate into AWS Certificate Manager that can be used for TLS on both the AdminALB and the EngineALB. In this example the certificate works with ssoadmin.thomsonreuters.com and sso.thomsonreuters.com. This must be done for each region. The LBCertID value is the trailing string in the ARN of that certificate after upload- so for arn:aws:acm:us-east-1:400400400400:certificate/40040040-1ac4-4355-bf40-400006b9a365 the LBCertID value is 40040040-1ac4-4355-bf40-400006b9a365. Alternatively, you could choose to use AWS own's certificate service and update the CloudFormation template accordingly.

### ECR repositories
You will need to create Elastic Container Repositories in the AMERS, EMEA, and ASPAC regions labeled with the Asset Insight ID number you set for your environment. The AMERS region will need one labeled pfadmin and pfengine. EMEA and ASPAC will only need pfengine. If your prod AAID is 205529, you would name the AMERS ECR repos:
- a205529-pfadmin
- a205529-pfengine

### CloudFormation IAM Role
Create a role that will be used to run and manage the resources created by the CloudFormation template. Prefix this role with your Asset Insight ID. If your dev AAID were 205529, name the role a205529-cfrrole-dev. This template touches many services, so it needs many permissions. The simplest way to ensure the template can run is to attach the following prebuilt AWS policies:
- AmazonRDSFullAccess
- AmazonEC2FullAccess
- SecretsManagerReadWrite
- IAMFullAccess
- AmazonS3FullAccess
- CloudWatchFullAccess
- AmazonEC2ContainerServiceFullAccess
- AWSKeyManagementServicePowerUser
- AmazonSNSFullAccess
- AmazonRoute53FullAccess

Depending on your organizational policies, risk tolerance, and other factors, once the environment has been built, you may take an inventory of all objects created and apply customized policies that match the naming schema of the objects created:
>         {
>            "Action": "s3:*",
>            "Resource": [
>                "arn:aws:s3:::a205466-esso-extract-dev",
>                "arn:aws:s3:::a205466-esso-extract-dev/*"
>            ],
>            "Effect": "Allow",
>            "Sid": "VisualEditor1"
>        } 
as to restrict the scope of this role.

### Populate the Mappings in the CloudFormation Template
Populate all the values from your AWS environment into the Mappings section of the CloudFormation template. The list below gives a brief explanation of what each mapping requires.

EnvironmentMappings:
- MinClusterSize: Minimum count of EC2 instances in the ECS cluster/EC2 autoscaling group
- MaxClusterSize: Maximum count of EC2 instances in the ECS cluster/EC2 autoscaling group
- VPC: ID of the VPC
- AmersVPCCidrRange: CIDR range of the VPC for the AMERS region
- EmeaVPCCidrRange: CIDR range of the VPC for the EMEA region
- AspacVPCCidrRange: CIDR range of the VPC for the ASPAC region
- SubnetPrivateA: ID of Private Subnet A
- SubnetPrivateB: ID of Private Subnet B
- SubnetPrivateC: ID of Private Subnet C
- SubnetPublicA: ID of Public Subnet A
- SubnetPublicB: ID of Public Subnet B
- SubnetPublicC: ID of Public Subnet C
- WebWorldSecurityGroup: Security Group ID of group that allows traffic from the internet on 80 & 443
- WebCorpSecurityGroup: Security Group ID of group that allows traffic only from corporate IP ranges
- BastionSSHSecurityGroup: Security Group ID of group that allows SSH access to EC2 instances
- KeyPrincipal1: ARN of the role that is used to run the CloudFormation template
- LBCertID: 46177819-1ac4-4355-bf38-580706b9a365
AWSRegionMappings
- AWSRegionAbbreviation: A short abbreviation for each AZ, must match the values used in the `create_cli_commands.py` script, e.g. use1
- AvailabilityZoneA: Name of the availability zone, e.g. us-east-1a
- AvailabilityZoneB: Name of the availability zone, e.g. us-east-1b
- AvailabilityZoneC: Name of the availability zone, e.g. us-east-1c
- DBSubnetGroup: Name of the DB subnet group that the RDS instance will use, e.g. tr-vpc-1-db-subnetgroup
- AMI: The AMI ID to be used with the EC2 instances that will comprise the ECS cluster, should be Amazon ECS-optimized Linux.

### Ensure the CloudWatch Route53 Failover Alarms are Commented for the First Run
The last resources created by the template are 9 CloudWatch alarms that alert when the Route53 healthcheck fails and Route53 routes traffic from one region to another. These alarms can only be created in us-east-1, and only after all the Route53 aliases and ALBs in your environment are created. These alarms are:
- AmersFailoverPrimaryAlarm
- EMEAFailoverPrimaryAlarm
- ASPACFailoverPrimaryAlarm

### Set a CNAME Alias in Your Enterprise DNS for the Route53 ALB Aliases
This could be done after the environment build if you are fine clearing the certficiate name mismatch until this step is completed. To make sure you never need to change your DNS aliases, and that you present the desired branding in your endpoints, create an alias record for the DNS names on the muilti-SAN certificate to match the Route53 ALB aliases. This will mate the desired URL with all the geographic routing and failover policy built into the CloudFormation template. We recommend matching environment suffixes:
- ssoadmin.thomsonreuters.com -> ssoadmin-prod.tr-aws.thomsonreuters.com.
- sso.thomsonreuters.com -> sso-prod.tr-aws.thomsonreuters.com.
- ssoadmin-qa.thomsonreuters.com -> ssoadmin-qa.tr-aws-non-prod.thomsonreuters.com.
- sso-qa.thomsonreuters.com -> sso-qa.tr-aws-non-prod.thomsonreuters.com.
- ssoadmin-qa.thomsonreuters.com -> ssoadmin-qa.tr-aws-non-prod.thomsonreuters.com.
- sso-qa.thomsonreuters.com -> sso-qa.tr-aws-non-prod.thomsonreuters.com.
- ssoadmin-dev.thomsonreuters.com -> ssoadmin-dev.tr-aws-non-prod.thomsonreuters.com.
- sso-dev.thomsonreuters.com -> sso-dev.tr-aws-non-prod.thomsonreuters.com.

## Building the Environment

### About the `create_cli_commands.py` script
As written, this repository creates the following docker images in the following regions:
- pfadmin us-east-1
- pfengine us-east-1
- pfprovisionser us-east-1
- pfengine eu-west-1
- pfengine ap-southeast-1

The `create_cli_commands.py` script helps you set the various regional and environmental parameters for those images, and then outputs the commands that need to be run in order to generate the correct docker images for the correct regions. You may adjust the values for each region and environment by editing the `def environment_mapped_values(environment)` block of the `create_cli_commands.py` script.

**You do not need to use the `create_cli_commands.py` script if you are comfortable creating your own ECR logon strings, docker build, and docker push commands, and manually build the changesets in CloudFormation via the administrative UI of AWS.**

Use `create_cli_commands.py` script with an environment argument to generate the following:
- An ECR login command for each region in use in the environment
- The docker build and push commands for the nodes necessary for each region in the environment
- The CloudFormation create-change-set command (including the template file S3 upload command) for the environment

Uses:
- `python3 create_cli_commands.py prod`
- `python3 create_cli_commands.py qa`
- `python3 create_cli_commands.py dev`

If enviroment/region/noderole build configurations need to change, the values in the `create_cli_commands.py` script should be updated.

The value of this script is that it holds all the logic needed to boil down all Docker build variables and CloudFormation change set creation launch variables to one input: environment. This logic will be transitioned to scripts that Jenkins can leverage to generate CloudFormation change sets - either automatically (e.g., when merges occur on monitored branches such as master) or manually (e.g., for dev work against temporary dev branches).

Copy and paste the commands into a terminal to log into ECR, build the docker images, and execute the CloudFormation template.

Note that the ECR login command makes some assumptions as to the environment names in your .aws_profile. You can either edit the ECR login commands manually to get the ECR token, or edit the `create_cli_commands.py` to match the AWS profile names you designate in your .aws_profile.

## AWS Environment Post-Build Tasks

### Populate the Route53 Failover HealthCheck IDs
Once you have run the CloudFormation template in all regions, capture the HealthcheckIDs for each of the Route53 ALB Aliases from Route53 and update the HealthCheckID values per environment under EnvironmentTypeMappings:
- AmersPrimaryHealthCheckId
- EmeaPrimaryHealthCheckId
- AspacPrimaryHealthCheckId

With these values populated, re-run the template in us-east-1 to create the CloudWatch alarms on all aliases.

### Run the Database Scripts for Client, Grant, and Outbound Provisioning
Configure a client to connect to the RDS instance, and retrieve the RDS secret from Secrets Manager. Pull the following scripts from the pingfederate-9.x.x.zip file and run them in the database:
- `oauth-client-management-postgresql.sql`
- `access-grant-attribute-postgresql.sql`
- `provisioner-postgresql.sql`

## PingFederate Post-Build Tasks
Sign into the PingFederate administrative console and begin configuring. The `replicate.sh` script will synch all nodes every five minutes.

### Connect the OAuth Database
Connect the RDS instance as a data store in PingFed. **You must connect it using the OAuthStoreAlias value so that the SystemID generated by PingFed will remain constant.** Capture the SystemID for that connection, and update the **rds_store** value in "def environment_mapped_values(environment):" in `create_cli_commands.py` from "PFDefaultDS" to that SystemID. Repeat for each environment.

### Using `export.sh`
The `export.sh` script will export a copy of the config every half hour from system launch, and  If you refresh the containers or delete the running tasks, the admin node will pull the latest copy of the configuration extract from the S3 extract bucket and load it into the drop-in-deployer on start up, and retain your configuration. However, in order to use this script you must provide an administrative account with Admin and Crypto Admin roles to call the admin API. If you choose to use this feature, ensure that your repository is private, your EC2 hosts and containers are private, and that only the appropriate administrators can access your environments. This is the biggest opportunity for improvement in the author's opinion- perhaps a python based process that composes the base64 authorization header after pulling the credentials from AWS Secrets Manager.

Create an admnistrative user with Crypto Admin and Admin. Encode the username:password for this user into base64 and populate that value in the pf_header value in `create_cli_commands.py` for the environment that matches that administrator. The `export.sh` script wil export the server configuration to an S3 bucket under the file names data.zip and data_dd_mm_yyyy.zip every half hour. When the environment refreshes, the admin node reaches into that S3 bucket and looks for the data.zip file, and places it into the drop-in-deployer.

If you choose not to use the `export.sh` script, manual exports of the server config to the S3 bucket to a data.zip file will allow the server configuration to be bootstrapped.

### (Optional) Rebuild the Containers
Re-run `create_cli_commands.py` and execute the docker build commands to rebuild and push the containers with the new values into ECR. Afterwards, you may terminate all running tasks in each ECS cluster in all environments to ensure the new containers load and work as expected. It is advised that you verify a config export has occured so that the latest configuration is in the S3 extract folder for the new containers to find on start up. 