#!/bin/bash

case $VERB in
  "install")
    echo "Installing nginx $PROJECT-nginx [$NGINXIP]"
    
    mkdir -p $SRV/nginx/etc/
    cp etc/nginx.conf $SRV/nginx/etc/
    
    docker $DOCKERARGS create \
      --name $PROJECT-nginx \
      --hostname $PROJECT-nginx \
      --net $PROJECT-net \
      --ip $NGINXIP \
      -p 8080:80 \
      -v $SRV/nginx/etc/nginx.conf:/etc/nginx/nginx.conf:ro \
      -v $SRV/nginx/etc/sites.conf:/etc/nginx/sites.conf:ro \
      nginx
      
    echo "
server {
  listen 80;
  server_name $DOMAIN;

  location /gitlab {
    proxy_pass http://$GITLABIP;
  }
  
  #location /hub {
  #  proxy_pass http://$PROJECT-jupyterhub:8000;
  #}
  
  location /owncloud {
    proxy_pass http://$OWNCLOUDIP;
  }
}
" > $SRV/nginx/etc/sites.conf

  ;;
  "start")
    echo "Starting nginx $PROJECT-nginx [$NGINXIP]"
    docker $DOCKERARGS start $PROJECT-nginx
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping nginx $PROJECT-nginx [$NGINXIP]"
    docker $DOCKERARGS stop $PROJECT-nginx
  ;;
  "remove")
    echo "Removing network $PROJECT-net [$SUBNET]"
    docker $DOCKERARGS rm $PROJECT-nginx
  ;;
  "purge")
    echo "Purging nginx $PROJECT-nginx [$NGINXIP]"
    rm -R $SRV/nginx/etc/
  ;;
esac