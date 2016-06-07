FROM jupyterhub/jupyterhub

RUN apt-get update && \
    apt-get -y install libnss-ldapd

ADD wrapper.sh /

ADD etc/* /etc/
RUN chmod 0700 /etc/nslcd.conf

CMD ["/bin/bash", "/wrapper.sh"]