FROM ubuntu:xenial

RUN apt-get update && apt-get install -y \
		gcc \
		gettext \
		mysql-client libmysqlclient-dev \
		postgresql-client libpq-dev \
                vim less \
                ssh git\
		python3-pip python3-dev\
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV DJANGO_VERSION 1.9

RUN pip3 install setuptools
RUN pip3 install mysqlclient psycopg2 docker-py django-threadlocals GitPython netaddr django=="$DJANGO_VERSION"

RUN cd /opt
RUN git clone https://github.com/kooplex/kooplex-hub.git
RUN mv kooplex-hub kooplexhub
COPY settings.py /settings.py 

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

COPY Runserver.sh /Runserver.sh
RUN chmod a+x /Runserver.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./Runserver.sh"]
#CMD ["cd /kooplexhub/kooplexhub/;python3 manage.py runserver 0:80"]