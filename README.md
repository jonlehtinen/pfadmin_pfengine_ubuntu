# pfadmin_pfengine_ubuntu
Deploys PingFederate 9.0.2 in clustered mode as docker stack on a docker swarm.

This repository defines the creation of a docker stack to run on a docker swarm that will run PingFederate 9.0.2. 
Be advised that the YAML file has not been tuned. Please make adjustments for your use case. 
I offer no warranties for this configuration.

1) Setup a docker swarm - details can be found here: https://docs.docker.com/engine/swarm/

2) From the swarm manager, deploy the stack: docker stack deploy -c <path to pfcluster.yaml> <stack_name>

3) This launches 3 services, a single pfadmin instance, <n> pfengine instances, and the pfnet overlay network 
that ensures each container is discoverable to the other containers regardless the host they are deployed 
on to facilitate configuration discovery

4) Additional docker nodes can be added to the swarm as additional compute is required, and the pfengine 
service can be scaled to accommodate the additional load using the docker service scale pfengine=<n>. Additional pfengine 
containers will then be added to the swarm nodes in a round robin fashion based on the current count of containers running on
each swarm node. The pfengine can be similarly scaled down using the same command.

Once deployed and PingFederate configured with data stores, VIP, reverse proxies, and connections, you can save the 
configuration by zipping the pingfederate directory within the pfadmin container and building a new pfadmin:<newtag> docker 
image with that zipped directory replacing the original pingfederate-9.0.2.zip file used in the original docker image referenced
in my docker cloud repository. With creative scripting, one could arrange for this process to occur automatically so 
new admin container images with complete configurations could be created at intervals for convenient redeployment of the 
pfadmin service/instance.
