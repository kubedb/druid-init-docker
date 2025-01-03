FROM apache/druid:31.0.0 AS base

FROM alpine

COPY --from=base /opt/druid/extensions/mysql-metadata-storage/mysql-metadata-storage-31.0.0.jar /tmp/extensions/mysql-metadata-storage/mysql-metadata-storage-31.0.0.jar
COPY --from=base /opt/druid/conf /tmp/config/default-config
COPY ./scripts /tmp/scripts

RUN apk update && apk upgrade
RUN apk --no-cache add bash openjdk11-jre openssl
RUN wget -O /tmp/extensions/mysql-metadata-storage/mysql-connector-java-5.1.49.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar

RUN ["chmod", "+x", "/tmp/scripts/entrypoint.sh"]
RUN ["chmod", "+x", "/tmp/scripts/merge_config_properties.sh"]
RUN ["chmod", "+x", "/tmp/scripts/configure_tls.sh"]

RUN adduser -u 1000 -g 1000 -D druid

RUN mkdir -p /opt/druid/conf

RUN chown -R druid /opt/druid/conf
RUN chown -R druid /tmp

USER 1000

ENTRYPOINT ["/tmp/scripts/entrypoint.sh"]
