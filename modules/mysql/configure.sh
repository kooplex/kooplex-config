#!/bin/bash

case $VERB in
  "build")
    echo "Building mysql $PROJECT-mysql [$MYSQLIP]"
    
    mkdir -p $SRV/mysql
    docker $DOCKERARGS pull mysql:5.7
  
  ;;
  "install")
    echo "Installing mysql $PROJECT-mysql [$MYSQLIP]"

    cont_exist=`docker $DOCKERARGS ps -a | grep $PROJECT-mysql | awk '{print $2}'`
    if [ ! $cont_exist ]; then

    docker $DOCKERARGS create \
      --name $PROJECT-mysql \
      --hostname $PROJECT-mysql \
      --net $PROJECT-net \
      --ip $MYSQLIP \
      -e PUBLICIP=$MYSQLIP \
      -e ADMINIP=$MYSQLIP \
      --log-opt max-size=1m --log-opt max-file=3 \
      -v /etc/localtime:/etc/localtime:ro \
      -v $SRV/mysql:/var/lib/mysql \
      -e MYSQL_ROOT_PASSWORD=$MYSQLPASS \
      mysql:5.7
    else
     echo "$PROJECT-mysql is already installed"
    fi
  ;;
  "start")
    echo "Starting mysql $PROJECT-mysql [$MYSQLIP]"
    echo "AT RESTART THERE MIGHT BE PROBLEMS!!!!"
    docker $DOCKERARGS start $PROJECT-mysql
  ;;
  "init")

  ;;
  "stop")
    echo "Stopping mysql $PROJECT-mysql [$MYSQLIP]"
    docker $DOCKERARGS stop $PROJECT-mysql
  ;;
  "remove")
    echo "Removing mysql $PROJECT-mysql [$MYSQLIP]"
    docker $DOCKERARGS rm $PROJECT-mysql
  ;;
  "clean")
    echo "Cleaning image kooplex-mysql"
    docker $DOCKERARGS rmi kooplex-mysql
  ;;
  "purge")
    echo "Purging $SRV/mysql"
    rm -r $SRV/mysql
  ;;
esac