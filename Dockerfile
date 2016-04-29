FROM centos:7

RUN yum update -y; yum clean all; \
    yum install -y createrepo mkisofs openssh pykickstart; \
    yum clean all

WORKDIR /opt
COPY ./scripts /opt/scripts

ENV PATH $PATH:/opt/scripts
