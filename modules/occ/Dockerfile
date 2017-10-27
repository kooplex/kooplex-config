FROM ubuntu
MAINTAINER steger@complex.elte.hu

COPY owncloud.list /etc/apt/sources.list.d/owncloud.list
COPY Release.key /tmp/Release.key

RUN apt-key add - < /tmp/Release.key && rm /tmp/Release.key

RUN apt update
RUN apt install -y --no-install-recommends python3 python3-pip owncloud-client-cmd python3-setuptools
RUN pip3 install watchdog

COPY wd.py /wd.py
COPY start.sh /start.sh

CMD [ /start.sh ]

