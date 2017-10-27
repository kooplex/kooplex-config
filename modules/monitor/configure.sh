#!/bin/bash

case $VERB in
  "build")
    echo "Building image $PREFIX-monitor"
    docker $DOCKERARGS build -t $PREFIX-monitor .
  ;;
  "install")
    mkdir -p $SRV/_monitoring/data
    mkdir -p $SRV/_monitoring/scripts
    cp -r scripts/* $SRV/_monitoring/scripts/

    cont_exist=`docker $DOCKERARGS ps -a | grep $PROJECT-monitor | awk '{print $2}'`
    if [ ! $cont_exist ]; then
        docker $DOCKERARGS create  \
          --name $PROJECT-monitor \
          --hostname $PROJECT-monitor \
          --net $PROJECT-net \
          --ip $MONITORIP \
          --privileged \
          --log-opt max-size=1m --log-opt max-file=3 \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v $SRV/_monitoring/data/:/usr/local/apache2/htdocs/:rw \
          -v $SRV/_monitoring/scripts/:/opt/scripts/:rw \
          --volume=/var/run:/var/run:rw \
	  --volume=/sys:/sys:ro \
	  --volume=/var/lib/docker/:/var/lib/docker:ro \
	  --volume=/dev/disk/:/dev/disk:ro \
          	$PREFIX-monitor  
    fi
  
  
  ;;
  "start")
     echo "Start monitoring $PROJECT-monitor [$MONITORIP]"
     docker $DOCKERARGS start $PROJECT-monitor
  ;;
  "init")
    echo "Initialize monitoring $PROJECT-monitor [$MONITORIP]"
#    ocker $DOCKERARGS exec $PROJECT-mysql \
#    bash -c "echo \"GRANT ALL PRIVILEGES ON * . * TO 'kooplex'@'%';\" | mysql -u root --password=$MYSQLPASS"
  
  ;;
  "stop")
      echo "Stop monitoring $PROJECT-monitor [$MONITORIP]"
     docker $DOCKERARGS stop $PROJECT-monitor
  ;;
  "remove")
      echo "Remove monitoring container $PROJECT-monitor [$MONITORIP]"
     docker $DOCKERARGS rm $PROJECT-monitor
  ;;
  "purge")
      echo "Purge datafiles gathered by  monitoring $PROJECT-monitor [$MONITORIP]"
     docker $DOCKERARGS start $PROJECT-monitor
  ;;
  "clean")
    echo "Cleaning base image $PREFIX-monitor"
    docker $DOCKERARGS rmi $PREFIX-monitor
  ;;
esac
