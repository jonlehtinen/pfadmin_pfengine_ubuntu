FROM ubuntu:16.04

# update utilities and get unzip
RUN apt-get update && apt-get install -y unzip

# set work directory
WORKDIR /opt

# add binaries
COPY server-jre-8u162-linux-x64.tar.gz /opt
ADD pingfederate-9.0.2.zip /opt
COPY run.properties /opt

# extract binaries
RUN unzip pingfederate-9.0.2.zip
RUN tar -xf server-jre-8u162-linux-x64.tar.gz

# define this as the cluster's PFAdmin node
RUN rm /opt/pingfederate-9.0.2/pingfederate/bin/run.properties
RUN cp -t /opt/pingfederate-9.0.2/pingfederate/bin /opt/run.properties 

# cleanup installation files
RUN rm /opt/pingfederate-9.0.2.zip && rm /opt/server-jre-8u162-linux-x64.tar.gz && rm /opt/run.properties

# set JAVA_HOME
ENV JAVA_HOME /opt/jdk1.8.0_162

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

