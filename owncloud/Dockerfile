FROM owncloud

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -q -y \
    libnss-ldapd openldap-utils ldap-client libldap2-dev 

RUN a2enmod authnz_ldap  
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.a /usr/lib/  
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/  

RUN \
    apt-get update && \
    apt-get install libldap2-dev -y && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

COPY etc/pam.d/* /etc/pam.d/
COPY etc/nsswitch.conf /etc/nsswitch.conf
COPY etc/nslcd.conf /etc/nslcd.conf
RUN chmod 0600 /etc/nslcd.conf

COPY entrypoint.sh /entrypoint.sh
ADD wrapper.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "/wrapper.sh"]
