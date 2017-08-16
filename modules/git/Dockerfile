FROM kooplex-base

MAINTAINER Kooplex Team <kooplex@complex.elte.hu

RUN apt update 
RUN apt install -y curl git
RUN apt clean

COPY nsswitch.conf /etc
COPY nslcd.conf /etc
COPY start.sh /init
COPY init-ssh-agent.sh /usr/local/bin
