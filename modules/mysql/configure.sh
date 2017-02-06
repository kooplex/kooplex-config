#!/bin/bash

case $VERB in
  "build")
    echo "Building mysql $PROJECT-mysql [$MYSQLIP]"
    
    mkdir -p $SRV/mysql
    docker $DOCKERARGS pull mysql:5.7
  
  ;;
  "install")
    echo "Installing mysql $PROJECT-mysql [$MYSQLIP]"
    
    MYSQLPASS=$(getsecret mysql)

    docker $DOCKERARGS create \
      --name $PROJECT-mysql \
      --hostname $PROJECT-mysql \
      --net $PROJECT-net \
      --ip $MYSQLIP \
      -p $MYSQLPORT:3306 \
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
  "check")
    echo "Checking mysql $PROJECT-mysql [$MYSQLIP]"
    
    MYSQLPASS=$(getsecret mysql)
    
    echo "Accessing via $MYSQLIP:"
    mysql -h $MYSQLIP -u root -p$MYSQLPASS -e "SHOW DATABASES;"
    echo "Accessing via localhost:"
    mysql -h 127.0.0.1 -u root -p$MYSQLPASS -e "SHOW DATABASES;" --port $MYSQLPORT
  ;;
  "stop")
    echo "Stopping mysql $PROJECT-mysql [$MYSQLIP]"
    docker $DOCKERARGS stop $PROJECT-mysql
  ;;
  "remove")
    echo "Removing mysql $PROJECT-mysql [$MYSQLIP]"
    docker $DOCKERARGS rm $PROJECT-mysql
  ;;
  "purge")
    echo "Purging $SRV/mysql"
    rm -r $SRV/mysql
  ;;
  "clean")
    echo "Cleaning image kooplex-mysql"
    docker $DOCKERARGS rmi kooplex-mysql
  ;;
esac