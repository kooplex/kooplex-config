# Based on:  https://docs.docker.com/engine/examples/running_ssh_service/
FROM debian:jessie

MAINTAINER COMPARE-WIGNER-NODE

RUN apt-get update
RUN apt-get install -y ldap-utils git openssh-server python-dev python-pip vim nfs-common
RUN apt-get install -y apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-cache policy docker-engine
RUN apt-get update && apt-get install -y docker-engine
RUN pip install --upgrade pip
RUN pip install numpy argparse datetime
RUN mkdir /var/run/sshd
RUN echo 'root:c0mp4r3' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#BASE.*/BASE dc=compare,dc=vo,dc=elte,dc=hu/' /etc/ldap/ldap.conf
RUN sed -i 's/#URI.*/URI ldap:\/\/compare-ldap:389/' /etc/ldap/ldap.conf
#RUN mount -t nfs -o proto=tcp,port=2049 172.18.0.4:/home /home

ARG BRANCHVAR
ARG PROJECT
ARG ROOT
ARG SUBNET
ARG DOMAIN
ARG SMTP
ARG EMAIL
ARG DUMMYPASS

RUN git clone --branch $BRANCHVAR https://github.com/eltevo/compare-config.git /tmp/compare-config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]