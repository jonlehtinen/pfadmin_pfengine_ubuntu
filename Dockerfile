FROM ubuntu:18.04

ARG AAID
ARG ENVNAME
ARG ENVURLLABEL
ARG PFHEADER
ARG RDSSTORE
ARG AWSREGION
ARG NODEROLE
ARG PROVISIONER
ARG PFVERSION

COPY docker-build-files /tmp/docker-build-files

WORKDIR /opt/pingfederate-${PFVERSION}/pingfederate

RUN apt-get update \
 && apt-get install unzip curl awscli vim -y \
 && unzip /tmp/docker-build-files/pingfederate-*.zip -d /opt \
 && ls /tmp/docker-build-files/openj*.tar.gz | xargs -i tar -xf {} -C /opt \
 && cp -r /tmp/docker-build-files/pingfederate/* . \
 && groupadd -r a${AAID}-PowerUser2 \
 && useradd -r -g a${AAID}-PowerUser2 a${AAID}-PowerUser2 \
 && chown -R a${AAID}-PowerUser2:a${AAID}-PowerUser2 . \
 && rm -r /tmp/docker-build-files

ENV JAVA_HOME /opt/jdk-11.0.1
ENV PF_HOME /opt/pingfederate-${PFVERSION}/pingfederate
ENV DATA_HOME s3://a${AAID}-esso-extract-${ENVNAME}
ENV ENV_USER a${AAID}-PowerUser2
ENV NODE_ROLE ${NODEROLE}

RUN sed -i "s/pf.operational.mode=STANDALONE/pf.operational.mode=${NODEROLE}/g" ./bin/run.properties \
 && sed -i "s/pf.cluster.auth.pwd=/pf.cluster.auth.pwd=ass4u6xKaLDTcGrmuOu${AAID}/g" ./bin/run.properties \
 && sed -i "s/AAID/${AAID}/g" ./server/default/conf/tcp.xml \
 && sed -i "s/RDSSTORE/${RDSSTORE}/g" ./server/default/data/config-store/org.sourceid.oauth20.token.AccessGrantManagerJdbcImpl.xml \
 && sed -i "s/RDSSTORE/${RDSSTORE}/g" ./server/default/data/config-store/org.sourceid.oauth20.domain.ClientManagerJdbcImpl.xml \
 && sed -i "s/node.group.id=/node.group.id=${AWSREGION}/g" ./server/default/conf/cluster-adaptive.conf

RUN if [ ${NODEROLE} = "CLUSTERED_CONSOLE" ]; then \
    sed -i "s,PF_REPLICATE,https://ssoadmin${ENVURLLABEL}.thomsonreuters.com/pf-admin-api/v1/cluster/replicate,g" ./bin/replicate.sh; \
    sed -i "s/PF_HEADER/${PFHEADER}/g" ./bin/replicate.sh; \
    sed -i "s,PF_EXPORT,https://ssoadmin${ENVURLLABEL}.thomsonreuters.com/pf-admin-api/v1/configArchive/export,g" ./bin/export.sh; \
    sed -i "s/PF_HEADER/${PFHEADER}/g" ./bin/export.sh; \
    chmod +x ./bin/replicate.sh; \
    chmod +x ./bin/export.sh; \
 else \
    rm ./bin/replicate.sh && rm ./bin/export.sh; \
 fi

RUN if [ ${NODEROLE} = "CLUSTERED_ENGINE" ]; then \
    sed -i "s/pf.provisioner.mode=OFF/pf.provisioner.mode=${PROVISIONER}/g" ./bin/run.properties; \
 fi

EXPOSE 9999 9031 7600 7601 7700 7500

USER a${AAID}-PowerUser2:a${AAID}-PowerUser2

ENTRYPOINT ["./bin/startup.sh"]
