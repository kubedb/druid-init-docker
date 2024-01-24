FROM apache/druid:{DRUID_VERSION} AS base

FROM alpine

COPY --from=base /opt/druid/extensions/mysql-metadata-storage/mysql-metadata-storage-{DRUID_VERSION}.jar /tmp/extensions/mysql-metadata-storage/mysql-metadata-storage-{DRUID_VERSION}.jar
COPY --from=base /opt/druid/conf /tmp/config/default-config
COPY ./scripts /tmp/scripts

RUN apk --no-cache add bash

RUN wget -O /tmp/extensions/mysql-metadata-storage/mysql-connector-java-5.1.49.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar

RUN ["chmod", "+x", "/tmp/scripts/entrypoint.sh"]
RUN ["chmod", "+x", "/tmp/scripts/merge_config_properties.sh"]

RUN adduser -u 1000 -g 1000 -D druid

RUN mkdir -p /opt/druid/conf
RUN chown -R druid /opt/druid/conf
RUN chown -R druid /tmp
USER 1000

ENTRYPOINT ["/tmp/scripts/entrypoint.sh"]
