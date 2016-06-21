FROM jupyterhub/jupyterhub

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y install libnss-ldapd

RUN pip3 install git+https://github.com/kooplex/oauthenticator.git

COPY etc/pam.d/* /etc/pam.d/
COPY etc/nsswitch.conf /etc/nsswitch.conf
COPY etc/nslcd.conf /etc/nslcd.conf
RUN chmod 0600 /etc/nslcd.conf

ADD wrapper.sh /

CMD ["/bin/bash", "/wrapper.sh"]