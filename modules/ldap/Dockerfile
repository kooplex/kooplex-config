FROM debian:jessie

MAINTAINER Laszlo Dobos <dobos@complex.elte.hu>
# Based on by dinkel/openldap by Christian Luginbühl <dinkel@pimprecords.com>

USER root

ENV OPENLDAP_VERSION 2.4.40

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        slapd=${OPENLDAP_VERSION}* vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mv /etc/ldap /etc/ldap.dist

COPY modules/ /etc/ldap.dist/modules

VOLUME ["/etc/ldap", "/var/lib/ldap"]

RUN chown -R openldap:openldap /etc/ldap && \
    chown -R openldap:openldap /var/lib/ldap/ /var/run/slapd/

EXPOSE 389

COPY entrypoint.sh /entrypoint.sh

RUN chown root /entrypoint.sh && \
    chmod 700 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["slapd", "-d", "32768", "-u", "openldap", "-g", "openldap"]