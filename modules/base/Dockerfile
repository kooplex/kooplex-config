FROM ubuntu:bionic

MAINTAINER Kooplex Team <kooplex@complex.elte.hu>

USER root

# configure apt frontent
ENV DEBIAN_FRONTEND noninteractive

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
# Install NFS client ACL manipulation
RUN apt-get update && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo vim\
    locales nfs-common acl nfs4-acl-tools

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.9.0/tini && \
    echo "faafbfb5b079303691a939a747d7f60591f2143164093727e870b289a44d9872 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Install LDAP and setup authentication
RUN touch /etc/nslcd.conf && \
    chmod 0600 /etc/nslcd.conf

RUN apt-get install -q -y libnss-ldapd openldap-utils ldap-client libldap2-dev 


RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.a /usr/lib/  
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/  

# Do not run nslcd as a daemon
RUN apt install -y systemd 
RUN systemctl disable nslcd
#RUN service nslcd disable

ADD entrypoint.sh /entrypoint.sh

RUN pam-auth-update --package

# Patch bashrc
COPY bashrc_tail /tmp
RUN cat /tmp/bashrc_tail >> /etc/bash.bashrc
RUN rm /tmp/bashrc_tail

EXPOSE 111/udp

RUN mkdir /init

# we don't run apt-get clean, coz the apt-cache is useful when preparing new module volumes
RUN rm -rf /var/lib/apt/lists/*

ENV SSH_AUTH_SOCK /tmp/my_sshagent_sock

ENTRYPOINT ["tini", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]
