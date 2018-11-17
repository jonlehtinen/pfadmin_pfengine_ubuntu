Deploys PingFederate 9.1.1 in clustered mode as docker stack on a docker swarm.

This repository defines the creation of a docker stack to run on a docker swarm that will run PingFederate 9.1.1. Be advised that the YAML file has not been tuned. Please make adjustments for your use case. I offer no warranties for this configuration.

Use the pfcluster.yaml file to launch a swarm cluster in a minimalist, clustered configuration with no license. Or use the dockerfiles and scripts to build out our youur own docker images to containerize your own PingFederate environment. Several sections are commented out of the dockerfiles by default for things like configuration imports, branding, and license import.

Setup a docker swarm - details can be found here: https://docs.docker.com/engine/swarm/

From the swarm manager, deploy the stack: docker stack deploy -c <stack_name>

This launches 3 services, a single pfadmin instance, pfengine instances, and the pfnet overlay network that ensures each container is discoverable to the other containers regardless the host they are deployed on to facilitate configuration discovery

Additional docker nodes can be added to the swarm as additional compute is required, and the pfengine service can be scaled to accommodate the additional load using the docker service scale pfengine=<Number>. Additional pfengine containers will then be added to the swarm nodes in a round robin fashion based on the current count of containers running on each swarm node. The pfengine can be similarly scaled down using the same command.

The tcp.xml is configured to use the default IP range-based discovery for cluster joining. You can use the AWS tag discovery for cluster joining. The dockerfile and the tcp.xml may need to be adjusted to use a different clustering mechanism to match your use case.

The service now launches under a non-root user:group called pingfederate:pingfederate

Several additional sections have been commented out of the dockerfile, and can be enabled if you provide the files to customize your PingFederate deployment-
1) The license file can be auto loaded.
2) You can rebuild this image with an export of an existing PingFederate server configuration as data.zip to pre-load connection information into your containers.
3) The main.css, html.form.login.template.html, companylogo.png and companyfont.zip can be added to enable branded logon pages.
4) The hivemodule.xml and org.sourceid.oauth20.domain.ClientManagerJdbcImpl.xml can be updated to refer to a persistent PostgreSQL data store once configured. Udpate the dockerfile and your files with the appropriate driver and files if you are usign a different data store type, like MySQL.

The files are provided under the MIT license.

Copyright  2018 Jon Lehtinen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
