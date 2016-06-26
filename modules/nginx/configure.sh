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
      -v $SRV/nginx/etc/nginx.conf:/etc/nginx/nginx.conf:ro \
      -v $SRV/nginx/etc/sites.conf:/etc/nginx/sites.conf:ro \
      nginx
      
    echo "
server {
  listen 80;
  server_name $DOMAIN;
  client_max_body_size 20M;
  
  location /gitlab {
    proxy_set_header Host \$http_host;
    proxy_pass http://$GITLABIP;
  }

  location /notebook {
    proxy_set_header      Host \$http_host;
    proxy_pass            http://$PROXYIP:8000;
    # websocket support
    proxy_http_version    1.1;
    proxy_set_header      Upgrade \"websocket\";
    proxy_set_header      Connection \"Upgrade\";
    proxy_read_timeout    86400;
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
    rm -R $SRV/nginx
  ;;
esac