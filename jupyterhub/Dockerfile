FROM jupyterhub/jupyterhub

RUN apt-get update && \
    apt-get -y install libnss-ldapd

ADD wrapper.sh /

CMD ["/bin/bash", "/wrapper.sh"]