#!/bin/bash

case $VERB in
  "build")
    echo "Building proxy $PROJECT-proxy [$PROXYIP]"
    docker $DOCKERARGS build -t kooplex-proxy .
  
  ;;
  "install")
    echo "Installing proxy $PROJECT-proxy [$PROXYIP]"
    
    PROXYTOKEN=$(getsecret proxy)
    
    docker $DOCKERARGS create \
      --name $PROJECT-proxy \
      --hostname $PROJECT-proxy \
      --net $PROJECT-net \
      --ip $PROXYIP \
      -e PUBLICIP=$PROXYIP \
      -e ADMINIP=$PROXYIP \
      -e CONFIGPROXY_AUTH_TOKEN=$PROXYTOKEN \
      -p 8001:8001 \
      kooplex-proxy
  ;;
  "start")
    echo "Starting proxy $PROJECT-proxy [$PROXYIP]"
    docker $DOCKERARGS start $PROJECT-proxy
  ;;
  "init")
    
  ;;
  "check")
    echo "Checking proxy $PROJECT-proxy [$PROXYIP]"
    PROXYTOKEN=$(getsecret proxy)
	curl -H "Authorization: token $PROXYTOKEN" http://$PROXYIP:8001/api/routes
	echo ""
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