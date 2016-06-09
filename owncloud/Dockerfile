FROM owncloud

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -q -y libnss-ldapd

COPY etc/pam.d/* /etc/pam.d/
COPY etc/nsswitch.conf /etc/nsswitch.conf
COPY etc/nslcd.conf /etc/nslcd.conf
RUN chmod 0600 /etc/nslcd.conf

COPY entrypoint.sh /entrypoint.sh
ADD wrapper.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "/wrapper.sh"]
