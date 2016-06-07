FROM jupyterhub/jupyterhub

RUN apt-get update && \
    apt-get -y install libnss-ldapd

RUN pip3 install git+https://github.com/eltevo/oauthenticator.git

ADD wrapper.sh /

CMD ["/bin/bash", "/wrapper.sh"]