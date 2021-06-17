FROM app/docker-image:version
USER 0:0
COPY ./my-plugins/ /opt/kafka/plugins/
USER 1001
