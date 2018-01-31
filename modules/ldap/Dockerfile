FROM debian:jessie

MAINTAINER Laszlo Dobos <dobos@complex.elte.hu>
# Based on by dinkel/openldap by Christian Luginbühl <dinkel@pimprecords.com>

USER root

ENV OPENLDAP_VERSION 2.4.40

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        slapd=${OPENLDAP_VERSION}* vim ldap-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mv /etc/ldap /etc/ldap.dist

RUN chown -R openldap:openldap /var/run/slapd/

EXPOSE 389

COPY new_group.ldiftemplate /etc/ldap/new_group.ldiftemplate
COPY addgroup.sh /usr/local/bin/addgroup.sh

COPY entrypoint.sh /entrypoint.sh
COPY init.sh /init.sh
COPY init-core.sh /init-core.sh

RUN chown root /entrypoint.sh && \
    chmod 700 /entrypoint.sh /init.sh /init-core.sh /usr/local/bin/addgroup.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["slapd", "-d", "32768", "-u", "openldap", "-g", "openldap"]
