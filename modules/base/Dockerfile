FROM ubuntu:xenial

MAINTAINER Laszlo Dobos <dobos@complex.elte.hu>

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \
		wget \
		bzip2 \
		ca-certificates \
		sudo \
		acl \
		locales \
		nfs-common \
		inotify-tools \
		libnss-ldapd \ 
		openldap-utils \
		ldap-client \
		libldap2-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.9.0/tini && \
    echo "faafbfb5b079303691a939a747d7f60591f2143164093727e870b289a44d9872 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini
	
# LDAP config
RUN touch /etc/nslcd.conf && \
    chmod 0600 /etc/nslcd.conf && \
	ln -s /usr/lib/x86_64-linuyx-gnu/libldap.a /usr/lib/ && \
	ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ && \
	systemctl disable nslcd && \
	pam-auth-update --package

ADD entrypoint.sh /entrypoint.sh

EXPOSE 111/udp

RUN mkdir /init

ENTRYPOINT ["tini", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]