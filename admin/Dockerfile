# Based on:  https://docs.docker.com/engine/examples/running_ssh_service/
FROM debian:jessie

MAINTAINER COMPARE-WIGNER-NODE

ARG PROJECT
ARG LDAPORG

# Update apt

RUN apt-get update
RUN apt-get install -y \
    apt-transport-https ca-certificates
    
# Install OS and docker packages

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-cache policy docker-engine
RUN apt-get update && apt-get install -y \
    sudo ldap-utils git openssh-server \
    python3-dev python3-pip vim nfs-common curl wget \
    docker-engine
    
# Update and install python packages

RUN pip3 install --upgrade pip
RUN pip3 install argparse datetime

#RUN mount -t nfs -o proto=tcp,port=2049 172.18.0.4:/home /home

# Configure sshd

RUN mkdir /var/run/sshd
RUN echo 'root:c0mp4r3' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#BASE.*/BASE $LDAPORG/' /etc/ldap/ldap.conf
RUN sed -i 's/#URI.*/URI ldap:\/\/$PROJECT-ldap:389/' /etc/ldap/ldap.conf

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]