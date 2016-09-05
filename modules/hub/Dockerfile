FROM kooplex-base

RUN apt-get update && apt-get install -y \
		gcc \
		gettext \
		mysql-server mysql-client libmysqlclient-dev \
		postgresql-client libpq-dev \
                vim less \
                git ssh\
		python3-pip \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
                python3-dev

ENV DJANGO_VERSION 1.9

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