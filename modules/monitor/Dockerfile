FROM httpd
MAINTAINER david.visontai@complex.elte.hu

USER root

# configure apt frontent
ENV DEBIAN_FRONTEND noninteractive

RUN chown root:root /tmp
RUN chmod 1777 /tmp

RUN apt update
RUN apt install -y --no-install-recommends python3 python3-pip python3-setuptools \
	 gcc python3-dev joe less
RUN apt install -y --no-install-recommends openssh-sftp-server  openssh-server

RUN pip3 install numpy psutil

#EXPOSE 22/tcp
#EXPOSE 22/udp

COPY start.sh /start.sh
RUN mkdir /opt/data 

CMD ["bash","/start.sh" ]

