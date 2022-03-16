##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
FROM app/docker-image:version
USER 0:0
COPY ./my-plugins/ /opt/kafka/plugins/
USER 1001
