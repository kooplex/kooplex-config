#!/bin/bash

case $VERB in
  "build")
    docker $DOCKERARGS build -t ${PREFIX}-home  .
  ;;
  "install")
  cont_exist=`docker $DOCKERARGS ps -a | grep $PROJECT-home | awk '{print $2}'`
    if [ ! $cont_exist ]; then
    docker $DOCKERARGS run -d -it \
      --name $PROJECT-home \
      --hostname $PROJECT-home \
      --net $PROJECT-net \
      --ip $HOMEIP \
      --privileged \
      --log-opt max-size=1m --log-opt max-file=3 \
      -v /etc/localtime:/etc/localtime:ro \
      -v $SRV/home:/home \
       ${PREFIX}-home bash
    else
     echo "$PROJECT-home is already installed"
    fi
  ;;
  "start")
    echo "Starting $PROJECT-home [$HOMEIP]"
    docker $DOCKERARGS start $PROJECT-home
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping nfs home $PROJECT-home [$HOMEIP]"
    docker $DOCKERARGS stop $PROJECT-home
  ;;
  "remove")
    echo "Removing nfs home $PROJECT-home [$HOMEIP]"
    docker $DOCKERARGS rm $PROJECT-home
  ;;
  "purge")
    echo "Purging nfs home $PROJECT-home [$HOMEIP]"
#    rm -R $SRV/home
  ;;
esac