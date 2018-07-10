FROM ubuntu:18.04

# update utilities and get unzip
RUN apt-get update && apt-get install -y unzip

# set work directory
WORKDIR /opt

# add binaries
COPY jre8-172.tar.gz /opt
ADD pingfederate-9.1.1.zip /opt
COPY run.properties /opt
COPY tcp.xml /opt

# extract binaries
RUN unzip pingfederate-9.1.1.zip
RUN tar -xf jre8-172.tar.gz

# define this as an engine node
RUN rm /opt/pingfederate-9.1.1/pingfederate/bin/run.properties 
RUN cp -t /opt/pingfederate-9.1.1/pingfederate/bin /opt/run.properties 

#Create logs on host
#VOLUME pflogs -v /home/ec2-user:/opt/pingfederate-9.1.1/pingfederate/log

# enables dynamic clustering via AWS Tag Descriptions (requires instances/user with Tag Description IAM role)
RUN rm /opt/pingfederate-9.1.1/pingfederate/server/default/conf/tcp.xml
RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/conf /opt/tcp.xml

# cleanup installation files
RUN rm /opt/pingfederate-9.1.1.zip && rm /opt/jre8-172.tar.gz && rm /opt/run.properties

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

