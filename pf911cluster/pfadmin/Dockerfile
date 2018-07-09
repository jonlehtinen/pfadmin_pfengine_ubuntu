FROM ubuntu:18.04

# update utilities and get unzip
RUN apt-get update && apt-get install -y unzip

# set work directory
WORKDIR /opt

# add binaries
COPY jre8-172.tar.gz /opt
COPY pingfederate-9.1.1.tar.gz /opt
COPY run.properties /opt
COPY tcp.xml /opt

# add configuration export if this is replacing existing configuration
# note that this WILL NOT auto-import the license file
#COPY data.zip /opt

# extract binaries
RUN tar -xf pingfederate-9.1.1.tar.gz
RUN tar -xf jre8-172.tar.gz

# define this as the cluster's PFAdmin node
RUN rm /opt/pingfederate-9.1.1/pingfederate/bin/run.properties 
RUN cp -t /opt/pingfederate-9.1.1/pingfederate/bin /opt/run.properties 

# enables dynamic clustering via AWS Tag Descriptions (requires instances/user with Tag Description IAM role)
RUN rm /opt/pingfederate-9.1.1/pingfederate/server/default/conf/tcp.xml
RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/conf /opt/tcp.xml

# load saved configuration if this replaces existing configuration
#RUN cp -t /opt/pingfederate-9.0.2/pingfederate/server/default/data/drop-in-deployer /opt/data.zip

#Create logs on host
#VOLUME pflogs -v /home/ec2-user:/opt/pingfederate-9.0.2/pingfederate/log  

# cleanup installation files
RUN rm /opt/pingfederate-9.1.1.tar.gz && rm /opt/jre8-172.tar.gz && rm /opt/run.properties

# cleanup of old config if used
#RUN rm /opt/data.zip 

# set JAVA_HOME
ENV JAVA_HOME /opt/jdk1.8.0_172

# open PF admin ports 
EXPOSE 9999
EXPOSE 9031
EXPOSE 7600
EXPOSE 7601
EXPOSE 7700
EXPOSE 7500

# write and execut pf startup script
COPY startup.sh /usr/bin/startup.sh
RUN chmod +x /usr/bin/startup.sh
ENTRYPOINT ["/usr/bin/startup.sh"] 

