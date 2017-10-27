#!/bin/bash

case $VERB in

  "build")
    echo "Building nginx $PROJECT-nginx [$NGINXIP]"

    mkdir -p $SRV/nginx/etc/
    cp etc/nginx.conf $SRV/nginx/etc/

    echo "
server {
  listen 80;
  server_name $REWRITEPROTO://$OUTERHOST;
  client_max_body_size 20M;

  access_log /var/log/nginx/${OUTERHOSTNAME}-access.log;
  error_log /var/log/nginx/${OUTERHOSTNAME}-error.log;

# DASHBOARD
  location ~* /db/(?<port>[0-9]*) {
    proxy_pass            http://${INNERHOST}:\$port;
    proxy_http_version    1.1;
    proxy_set_header      Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header      Upgrade \$http_upgrade;
    proxy_set_header      Connection "upgrade";
    proxy_read_timeout    86400;
  }
#END

  
  location /gitlab {
    proxy_set_header Host \$http_host;
    proxy_pass http://$GITLABIP;
  }

  location /hub {
    proxy_set_header Host \$http_host;
    proxy_pass http://$HUBIP;
  }

  location /admin {
    proxy_set_header Host \$http_host;
    proxy_pass http://$HUBIP/admin;
  }


  location / {
    rewrite / $REWRITEPROTO://$OUTERHOST/hub permanent;
  }

  location /static/ {
    proxy_set_header Host \$http_host;
    proxy_pass http://$HUBIP/static/;
  }

  location /notebook {
    proxy_set_header      Host \$http_host;
    proxy_pass            http://$PROXYIP:8000;
  }

#DASHBOARD SERVER
#  location ^~ /notebook/[^/]+/[^/]+/api/bundlers/dashboards_server_upload/? {
  location /notebook/gitlabadmin/07f159b4-99d4-47f9-9c91-d8654f3c70dc/api/bundlers/dashboards_server_upload/ {
    proxy_set_header      Host \$http_host;
    proxy_pass http://$DASHBOARDSIP:3000/;
  }


  
  location ~* /notebook/[^/]+/[^/]+/(api/kernels/[^/]+/(channels|iopub|shell|stdin)|terminals/websocket)/? {
    proxy_pass            http://$PROXYIP:8000;
    proxy_http_version    1.1;
    proxy_set_header      Host \$http_host;
    proxy_set_header      Upgrade \$http_upgrade;
    proxy_set_header      Connection \"upgrade\";
    proxy_read_timeout    86400;
  }

  location /ownCloud {
    proxy_pass http://$OWNCLOUDIP/;
    proxy_set_header Accept-Encoding \"\";
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    client_max_body_size 1024M;
    proxy_read_timeout 600s;
    proxy_send_timeout 600s;
    proxy_connect_timeout 600s;
    rewrite ^/ownCloud/caldav /ownCloud/remote.php/caldav redirect;
    rewrite ^/ownCloud/carddav /ownCloud/remote.php/carddav redirect;
    rewrite ^/ownCloud/webdav /ownCloud/remote.php/webdav redirect;
    rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
    rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;
    rewrite ^(/core/doc/[^\/]+/)$ \$1/index.html;
    rewrite ^/ownCloud/(.*) /\$1 break;

  }
}
  
  #DASHBOARD SERVER
  server {
  listen 3000;
  server_name $INNERHOST;
  client_max_body_size 20M;

  location / {
    proxy_set_header      Host \$http_host;
    proxy_pass            http://$DASHBOARDSIP:3000;
  }

}

" > $SRV/nginx/etc/sites.conf
;;
  "install")
    echo "Installing nginx $PROJECT-nginx [$NGINXIP]"
    

    
    cont_exist=`docker $DOCKERARGS ps -a | grep $PROJECT-nginx | awk '{print $2}'`
    if [ ! $cont_exist ]; then
    docker $DOCKERARGS create \
      --name $PROJECT-nginx \
      --hostname $PROJECT-nginx \
      --net $PROJECT-net \
      --ip $NGINXIP \
      -p 80:80 \
      --log-opt max-size=1m --log-opt max-file=3 \
      -v /etc/localtime:/etc/localtime:ro \
      -v $SRV/nginx/etc/nginx.conf:/etc/nginx/nginx.conf:ro \
      -v $SRV/nginx/etc/sites.conf:/etc/nginx/sites.conf:ro \
      -v $SRV/nginx/var:/var/log/nginx \
      nginx 
    else
     echo "$PROJECT-nginx is already installed"
    fi
      



  ;;
  "start")
    echo "Starting nginx $PROJECT-nginx [$NGINXIP]"
    docker $DOCKERARGS start $PROJECT-nginx
  ;;
  "restart")
    echo "Restarting nginx $PROJECT-nginx [$NGINXIP]"
    docker $DOCKERARGS stop $PROJECT-nginx
    docker $DOCKERARGS start $PROJECT-nginx
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping nginx $PROJECT-nginx [$NGINXIP]"
    docker $DOCKERARGS stop $PROJECT-nginx
  ;;
  "remove")
    echo "Removing nginx $PROJECT-net [$SUBNET]"
    docker $DOCKERARGS rm $PROJECT-nginx
  ;;
  "purge")
    echo "Purging nginx $PROJECT-nginx [$NGINXIP]"
    rm -R $SRV/nginx
  ;;
esac
