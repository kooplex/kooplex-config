#!/bin/bash

echo "Installing nginx $PROJECT-nginx [$NGINXIP]"

# Initialize nginx directory with necessary config files

mkdir -p $SRV/nginx/etc/
cp etc/nginx.conf $SRV/nginx/etc/

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

# Install and execute docker image

docker run -d \
  --name $PROJECT-nginx \
  --hostname $PROJECT-nginx \
  --net $PROJECT-net \
  --ip $NGINXIP \
  -v $SRV/nginx/etc/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $SRV/nginx/etc/sites.conf:/etc/nginx/sites.conf:ro \
  nginx

