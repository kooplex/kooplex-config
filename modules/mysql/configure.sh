#!/bin/bash

case $VERB in
  "build")
    echo "Building mysql $PROJECT-mysql [$MYSQLIP]"
    
    mkdir $SRV/mysql
    docker $DOCKERARGS pull mysql:5.7
  
  ;;
  "install")
    echo "Installing mysql $PROJECT-mysql [$MYSQLIP]"

    docker $DOCKERARGS create \
      --name $PROJECT-mysql \
      --hostname $PROJECT-mysql \
      --net $PROJECT-net \
      --ip $MYSQLIP \
      -e PUBLICIP=$MYSQLIP \
      -e ADMINIP=$MYSQLIP \
      -v $SRV/mysql:/var/lib/mysql \
      -e MYSQL_ROOT_PASSWORD=$MYSQLPASS \
      mysql:5.7
  ;;
  "start")
    echo "Starting mysql $PROJECT-mysql [$MYSQLIP]"
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