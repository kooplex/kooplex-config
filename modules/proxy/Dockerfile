FROM jupyter/configurable-http-proxy

MAINTAINER Laszlo Dobos <dobos@complex.elte.hu>

USER root

# Expose admin port. This is insecure now but we'll add SSL
# client certificates later.
EXPOSE 8001

WORKDIR /

ADD entrypoint.sh /entrypoint.sh

USER nobody

# Replace entry point to allow passing arguments
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]