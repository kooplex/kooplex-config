#!/bin/bash

echo "Initializing nginx $PROJECT-nginx [$NGINXIP]"

# Prepare configuration

echo "
server {
  listen 80;
  server_name $DOMAIN;

  location /gitlab {
    proxy_pass http://$PROJECT-gitlab;
  }
  
  location /hub {
    proxy_pass http://$PROJECT-jupyterhub:8000;
  }
}
" > $SRV/nginx/etc/sites.conf