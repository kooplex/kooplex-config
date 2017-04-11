#! /bin/bash
# Author: Jozsef Steger
# Summary: patch urls in static content

FLAGFILE=/srv/app/PATCHED

if [ ! $# -eq 2 ] ; then
  echo "Usage: $0 <dashboards_server_container_name> <BASE_URL>" >&2
  exit 1
fi

CONTAINER=$1
BASE_URL=$(echo $2 | sed s/'\/'/'\\\/'/g)

date

docker inspect $CONTAINER | grep -q -i '"Status": "running"'
if [ ! $? -eq 0 ] ; then
  echo "$CONTAINER is not running..." >&2
  exit 2
fi

function exc {
  if [ $1 = n ] ; then
    ex=$1
    shift
  else
    ex=y
  fi
  docker exec -it -u root $CONTAINER $@
  EXC_ST=$?
  if [ $ex = 'y' -a ! $EXC_ST = 0 ] ; then 
    echo "ERROR: failed to run $@ in container $CONTAINER" >&2
    exit 3
  fi
  echo "DEBUG: $@ returned $EXC_ST in container $CONTAINER" >&2
}

function ptch_css {
 exc sed -i.bak -e "s/\/components/$BASE_URL\/components/g" /srv/app/app/public/css/style.css
}

exc n ls $FLAGFILE
if [ $EXC_ST = 0 ] ; then
  echo "Already patched" >&2
  exit 0
fi

ptch_css
exc n touch $FLAGFILE
