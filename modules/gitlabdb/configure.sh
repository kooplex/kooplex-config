#!/bin/bash

case $VERB in
  "build")
    echo "Pulling postgres image $PROJECT-gitlabdb"
    docker pull postgres
  ;;
  "install")
    echo "Installing gitlabdb $PROJECT-gitlabdb [$GITLABDBIP]"
    cont_exist=`docker $DOCKERARGS ps -a | grep $PROJECT-gitlabdb | awk '{print $2}'`
    if [ ! $cont_exist ]; then
      docker $DOCKERARGS create \
        --name $PROJECT-gitlabdb \
        --hostname $PROJECT-gitlabdb \
        --net $PROJECT-net \
        --ip $GITLABDBIP \
        --env POSTGRES_PASSWORD=$GITLABDBPASS \
        postgres
    else
      echo "$PROJECT-gitlabdb is already installed"
    fi
  ;;
  "start")
    echo "Starting gitlabdb $PROJECT-gitlabdb [$GITLABDBIP]"
    docker $DOCKERARGS start $PROJECT-gitlabdb
    echo "Waiting 30 seconds because postgresql dbms of $PROJECT-gitlabdb has to be established before the following connection"
    sleep 30
    if ! docker $DOCKERARGS exec --user postgres $PROJECT-gitlabdb bash -c 'psql -lqt' | cut -d \| -f 1 | grep -qw gitlabhq_production ; then
      echo "Creating database gitlabhq_production for gitlab"
      docker $DOCKERARGS exec --user postgres $PROJECT-gitlabdb bash -c 'createdb gitlabhq_production'
    else
      echo "Database gitlabhq_production is already created"
    fi
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping gitlabdb $PROJECT-gitlabdb [$GITLABDBIP]"
    docker $DOCKERARGS stop $PROJECT-gitlabdb
  ;;
  "remove")
    echo "Removing gitlabdb $PROJECT-gitlabdb [$GITLABDBIP]"
    docker $DOCKERARGS rm $PROJECT-gitlabdb
  ;;
  "clean")
    echo "Removing gitlabdb image postgres"
    docker $DOCKERARGS rmi postgres
  ;;
  "purge")
  
  ;;
esac
