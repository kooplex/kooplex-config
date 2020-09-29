#!/bin/bash

cp /conf/nginx.conf /etc/nginx/ 
cp /conf/sites.conf /etc/nginx/

chown www-data:www-data -R /srv/consent/public/ /srv/consent/application/{cache,db/backups,logs,config,archives} /srv/consent/public/assets/cache
chmod u+w /srv/consent/public/ /srv/consent/application/{cache,db/backups,logs,config,archives} /srv/consent/public/assets/cache
chown www-data:www-data /srv/consent/application/config/application.php /srv/consent/application/config/database.php
chmod u+w  /srv/consent/application/config/application.php /srv/consent/application/config/database.php
ln -sf /srv/consent/public /srv/consent/public/consent
service nginx start
service php7.0-fpm start

sleep infinity
