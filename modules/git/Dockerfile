FROM kooplex-base
MAINTAINER Kooplex Team <kooplex@complex.elte.hu

COPY owncloud.list /etc/apt/sources.list.d/owncloud.list
COPY Release.key /tmp/Release.key

RUN apt-key add - < /tmp/Release.key && rm /tmp/Release.key

RUN apt update && \
    apt install -y --no-install-recommends curl git python3-pip python3-dev python3-setuptools owncloud-client
RUN apt clean

COPY nsswitch.conf /etc
COPY nslcd.conf /etc
COPY start.sh /init
COPY init-ssh-agent.sh /usr/local/bin
COPY patch.sh /usr/local/bin
COPY wd.py /usr/local/bin
COPY share.sh /usr/local/bin

RUN pip3 install watchdog
