FROM kooplex-base

MAINTAINER Laszlo Dobos <dobos@complex.elte.hu>
# based on the image cpuguy83/nfs-server by

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y -qq \
		xfsprogs nfs-kernel-server runit inotify-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /exports && \
    mkdir -p /etc/sv/nfs

ADD rpc-services /etc/services
ADD nfs-init.sh /etc/sv/nfs/run
ADD nfs-stop.sh /etc/sv/nfs/finish

VOLUME /exports

EXPOSE 111/udp 2049/tcp

