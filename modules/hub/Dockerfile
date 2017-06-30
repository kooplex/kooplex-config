FROM kooplex-base

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
RUN pip3 install ldap3
RUN pip3 install pwgen

# It is very important that the following command 'git clone...' cannot be cached
# (Based on https://github.com/docker/docker/issues/22832#issuecomment-220314032)
ARG CACHE_DATE=2016-01-02
RUN cd /opt 
RUN git clone -b devnew https://github.com/kooplex/kooplex-hub.git
RUN mv kooplex-hub kooplexhub
#COPY settings.py /settings.py 

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

COPY Runserver.sh /Runserver.sh
RUN chmod a+x /Runserver.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./Runserver.sh"]
#CMD ["cd /kooplexhub/kooplexhub/;python3 manage.py runserver 0:80"]
