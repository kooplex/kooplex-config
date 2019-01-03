FROM jupyter/configurable-http-proxy:3.1.1

MAINTAINER Kooplex Team <kooplex@complex.elte.hu>

USER root

# Expose admin port. This is insecure now but we'll add SSL
# client certificates later.
EXPOSE 8001

WORKDIR /

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER nobody

# Replace entry point to allow passing arguments
ENTRYPOINT ["/entrypoint.sh"]
