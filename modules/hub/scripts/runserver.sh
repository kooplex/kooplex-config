#! /bin/bash

#FIXME: this is not nice
env > /var/spool/cron/crontabs/root
echo -e "*/1 * * * * /usr/bin/python3 /kooplexhub/kooplexhub/manage.py scheduler\n" >> /var/spool/cron/crontabs/root
/etc/init.d/cron start

cd /kooplexhub/kooplexhub/
#git pull
/usr/bin/python3 manage.py makemigrations hub
/usr/bin/python3 manage.py migrate
/usr/bin/python3 manage.py runserver 0.0.0.0:80
