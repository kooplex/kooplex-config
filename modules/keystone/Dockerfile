FROM ubuntu:trusty

# =============================================================
# Basic setup
# =============================================================
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -yq \
        wget bzip2 ca-certificates sudo locales
    
# Set up locale
RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# =============================================================
# Install tini
# =============================================================
RUN cd /tmp && \
    wget --quiet https://github.com/krallin/tini/releases/download/v0.9.0/tini && \
    echo "faafbfb5b079303691a939a747d7f60591f2143164093727e870b289a44d9872 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini
        
# =============================================================
# Install keystone from github
# =============================================================
RUN apt-get install -yq --no-install-recommends \
        software-properties-common  python-software-properties && \
    add-apt-repository -y cloud-archive:mitaka && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
        keystone
RUN update-rc.d keystone disable

# =============================================================
# Clean up and set entrypoint
# =============================================================
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["tini", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]
