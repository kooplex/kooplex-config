#!/bin/bash

case $VERB in
  "build")
    echo "Building proxy $PROJECT-proxy [$PROXYIP]"
    docker $DOCKERARGS build -t kooplex-proxy .
  
  ;;
  "install")
    echo "Installing proxy $PROJECT-proxy [$PROXYIP]"
    
    PROXYTOKEN=$(createsecret proxy)
    
    cont_exist=`docker $DOCKERARGS ps -a | grep $PROJECT-proxy | awk '{print $2}'`
    if [ ! $cont_exist ]; then
    docker $DOCKERARGS create \
      --name $PROJECT-proxy \
      --hostname $PROJECT-proxy \
      --net $PROJECT-net \
      --ip $PROXYIP \
      -e PUBLICIP=$PROXYIP \
      -e ADMINIP=$PROXYIP \
      -e CONFIGPROXY_AUTH_TOKEN=$PROXYTOKEN \
      -p 8001:8001 \
      --log-opt max-size=1m --log-opt max-file=3 \
      -v /etc/localtime:/etc/localtime:ro \
      kooplex-proxy
    else
     echo "$PROJECT-proxy is already installed"
    fi
  ;;
  "start")
    echo "Starting proxy $PROJECT-proxy [$PROXYIP]"
    docker $DOCKERARGS start $PROJECT-proxy
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping proxy $PROJECT-proxy [$PROXYIP]"
    docker $DOCKERARGS stop $PROJECT-proxy
  ;;
  "remove")
    echo "Removing proxy $PROJECT-proxy [$PROXYIP]"
    docker $DOCKERARGS rm $PROJECT-proxy
  ;;
  "clean")
    echo "Cleaning image kooplex-proxy"
    docker $DOCKERARGS rmi kooplex-proxy
  ;;
esac