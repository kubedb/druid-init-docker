FROM apache/druid:{DRUID_VERSION} AS base

FROM alpine

COPY --from=base /opt/druid/extensions/mysql-metadata-storage/mysql-metadata-storage-{DRUID_VERSION}.jar /tmp/extensions/mysql-metadata-storage/mysql-metadata-storage-{DRUID_VERSION}.jar
COPY --from=base /opt/druid/conf /tmp/config/default-config
COPY ./scripts /tmp/scripts

RUN apk --no-cache add bash openjdk11-jre openssl

RUN wget -O /tmp/extensions/mysql-metadata-storage/mysql-connector-java-{MYSQL_CONNECTOR_VERSION}.jar {MYSQL_CONNECTOR_URL}

RUN ["chmod", "+x", "/tmp/scripts/entrypoint.sh"]
RUN ["chmod", "+x", "/tmp/scripts/merge_config_properties.sh"]
RUN ["chmod", "+x", "/tmp/scripts/configure_tls.sh"]

RUN adduser -u 1000 -g 1000 -D druid

RUN mkdir -p /opt/druid/conf \
    && mkdir -p /tmp/metadata

RUN chown -R druid /opt/druid/conf
RUN chown -R druid /tmp

USER 1000

ENTRYPOINT ["/tmp/scripts/entrypoint.sh"]
