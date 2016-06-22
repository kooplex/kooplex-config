# Based on the official docker image for jupyterhub

# Debian Jessie image released 2016 May 03.
FROM debian@sha256:32a225e412babcd54c0ea777846183c61003d125278882873fb2bc97f9057c51

MAINTAINER Laszlo Dobos <dobos@complex.elte.hu

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.9.0/tini && \
    echo "faafbfb5b079303691a939a747d7f60591f2143164093727e870b289a44d9872 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Install LDAP and setup authentication
ENV DEBIAN_FRONTEND=noninteractive

RUN touch /etc/nslcd.conf && \
    chmod 0600 /etc/nslcd.conf

RUN apt-get update && \
    apt-get install -q -y \
    libnss-ldapd openldap-utils ldap-client libldap2-dev 

RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.a /usr/lib/  
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/  

# Do not run nslcd as a daemon
RUN systemctl disable nslcd

ADD etc/pam.d/* /etc/pam.d/
ADD etc/nsswitch.conf /etc/nsswitch.conf
ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["tini", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]