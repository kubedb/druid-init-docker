FROM apache/druid:25.0.0 AS base

FROM alpine

COPY --from=base /opt/druid/extensions/mysql-metadata-storage/mysql-metadata-storage-25.0.0.jar /tmp/extensions/mysql-metadata-storage/mysql-metadata-storage-25.0.0.jar
COPY --from=base /opt/druid/conf /tmp/config/default-config
#RUN mkdir /tmp/scripts
COPY ./scripts /tmp/scripts

RUN apk --no-cache add bash

#RUN ls -l /tmp/scripts
#RUN chmod +x /tmp/scripts/run.sh
RUN wget -O /tmp/extensions/mysql-metadata-storage/mysql-connector-java-5.1.49.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar

RUN ["chmod", "+x", "/tmp/scripts/entrypoint.sh"]
RUN ["chmod", "+x", "/tmp/scripts/merge_config_properties.sh"]

#CMD ["bash", "/tmp/scripts/entrypoint.sh"]
#CMD ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/tmp/scripts/entrypoint.sh"]