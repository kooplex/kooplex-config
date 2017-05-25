FROM kooplex-base

MAINTAINER David Visontai <david.visontai@complex.elte.hu

RUN apt update
RUN apt install -y owncloud-client-cmd

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["bash"]


