#!/bin/bash

chown www-data:www-data -R /srv/public/ /srv/application/{cache,db/backups,logs,config,archives} /srv/public/assets/cache
chmod u+w /srv/public/ /srv/application/{cache,db/backups,logs,config,archives} /srv/public/assets/cache
chown www-data:www-data /srv/application/config/application.php /srv/application/config/database.php
chmod u+w  /srv/application/config/application.php /srv/application/config/database.php
ln -sf /srv/public /srv/public/consent
[ -f /etc/nginx/conf.d/default.conf ] && rm /etc/nginx/conf.d/default.conf
service nginx start
service php7.3-fpm start

sleep infinity
