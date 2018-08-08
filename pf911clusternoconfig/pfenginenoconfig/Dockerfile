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
COPY postgresql-42.2.2.jar /opt
#COPY hivemodule.xml /opt
#COPY org.sourceid.oauth20.domain.ClientManagerJdbcImpl.xml /opt
#COPY main.css /opt
#COPY pingfederate.lic /opt
#COPY companylog.png /opt
#COPY html.form.login.template.html /opt
#ADD companyfont.zip /opt
#COPY pingfederate-messages.properties /opt

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

# installs postgresql db driver
RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/lib /opt/postgresql-42.2.2.jar

# sets up PingFederate to use the PostgreSQL persistant grant datastore (ENVIRONMENT SPECIFIC!)
#RUN rm /opt/pingfederate-9.1.1/pingfederate/server/default/conf/META-INF/hivemodule.xml
#RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/conf/META-INF /opt/hivemodule.xml
#RUN rm /opt/pingfederate-9.1.1/pingfederate/server/default/data/config-store/org.sourceid.oauth20.domain.ClientManagerJdbcImpl.xml
#RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/data/config-store /opt/org.sourceid.oauth20.domain.ClientManagerJdbcImpl.xml

# customizes main.css and logon form
#RUN rm /opt/pingfederate-9.1.1/pingfederate/server/default/conf/template/assets/css/main.css
#RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/conf/template/assets/css /opt/main.css
#RUN rm /opt/pingfederate-9.1.1/pingfederate/server/default/conf/template/html.form.login.template.html
#RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/conf/template /opt/html.form.login.template.html
#RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/conf/template/assets/images /opt/companylogo.png
#RUN unzip -d /opt/pingfederate-9.1.1/pingfederate/server/default/conf/template/assets/fonts /opt/companyfont.zip
#RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/conf/language-packs /opt/pingfederate-messages.properties

# installs the PingFederate license file
#RUN cp -t /opt/pingfederate-9.1.1/pingfederate/server/default/conf /opt/pingfederate.lic

# cleanup installation files
RUN rm /opt/pingfederate-9.1.1.zip && rm /opt/jre8-172.tar.gz && rm /opt/run.properties && rm /opt/tcp.xml && rm /opt/postgresql-42.2.2.jar
#RUN rm /opt/main.css && rm /opt/companylog.png && rm /opt/html.form.login.template.html && rm /opt/pingfederate.lic && rm /opt/companyfont.zip && rm /opt/pingfederate-messages.properties && rm /opt/hivemodule.xml && rm /opt/org.sourceid.oauth20.domain.ClientManagerJdbcImpl.xml

# create a non-root user to run PingFederate
RUN groupadd -r pingfederate && useradd -r -g pingfederate pingfederate
RUN chown -R pingfederate:pingfederate /opt/pingfederate-9.1.1

# set JAVA_HOME
ENV JAVA_HOME /opt/jdk1.8.0_172

# open PF admin ports 
EXPOSE 9999
EXPOSE 9031
EXPOSE 7600
EXPOSE 7601
EXPOSE 7700
EXPOSE 7500

# write and change ownership of pf startup script
COPY startup.sh /usr/bin/startup.sh
RUN chmod +x /usr/bin/startup.sh
RUN chown pingfederate:pingfederate /usr/bin/startup.sh

# set the pingfederate user and entrypoint
USER pingfederate:pingfederate
ENTRYPOINT ["/usr/bin/startup.sh"] 