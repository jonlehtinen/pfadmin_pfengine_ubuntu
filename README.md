Deploys PingFederate 9.0.2 in clustered mode as docker stack on a docker swarm.

This repository defines the creation of a docker stack to run on a docker swarm that will run PingFederate 9.0.2. Be advised that the YAML file has not been tuned. Please make adjustments for your use case. I offer no warranties for this configuration.

Setup a docker swarm - details can be found here: https://docs.docker.com/engine/swarm/

From the swarm manager, deploy the stack: docker stack deploy -c <stack_name>

This launches 3 services, a single pfadmin instance, pfengine instances, and the pfnet overlay network that ensures each container is discoverable to the other containers regardless the host they are deployed on to facilitate configuration discovery

Additional docker nodes can be added to the swarm as additional compute is required, and the pfengine service can be scaled to accommodate the additional load using the docker service scale pfengine=<Number>. Additional pfengine containers will then be added to the swarm nodes in a round robin fashion based on the current count of containers running on each swarm node. The pfengine can be similarly scaled down using the same command.

Once deployed and PingFederate configured with data stores, VIP, reverse proxies, and connections, you can save the configuration in one of two ways:

First: Use the Configuration Archive tool in the Administrative Console to export a ZIP file with the server configuration. Rename that file to data.zip and rebuild the image with that file in the dockerfile directory. Also uncomment the relevant sections of the dockerfile for copying and updating the data.zip to the drop-in-deployer. If you user persistant grants stored in an external DB, note that you will need to add a line to the dockerfile to manually copy the hivemodule.xml to pingfederate/server/default/conf/META-INF/ as this file is NOT currently exported using the Configuration Archive tool.

Second: Zip the pingfederate directory within the pfadmin container and build a new pfadmin: docker image with that zipped directory replacing the original pingfederate-9.0.2.zip file used in the original docker image referenced in my docker cloud repository. With creative scripting, one could arrange for this process to occur automatically so new admin container images with complete configurations could be created at intervals for convenient redeployment of the pfadmin service/instance.

Additional items to consider:

Add additional IPs in run.properties within the subnet range for the pfnet overlay network for discovery if clusters are cycled through very rapidly to ensure continuity of replication.
If deploying in AWS, enable dhynamic discovery and configure a S3 bucket for discovery in the tcp.xml file as indicated in run.properties.