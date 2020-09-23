#!/bin/sh
echo $DATABASE_URL > /tmp/vmi

if [ ! -f /etc/hydra.csr ]; then 
    cp /conf/rootCA.key /etc/rootCA.key
    cp /conf/rootCA.crt /usr/local/share/ca-certificates/rootCA.crt
    openssl genrsa -out /etc/hydra.key 2048
    openssl req -new -sha256 -subj "/C=HU/ST=BP/L=Budapest/O=KRFT/CN=${PREFIX}-hydra" -key /etc/hydra.key -out /etc/hydra.csr
    openssl x509 -req -in /etc/hydra.csr -CA /usr/local/share/ca-certificates/rootCA.crt -CAkey /etc/rootCA.key -CAcreateserial -out /tmp/hydra.crt -days 1024 -sha256
    cat /tmp/hydra.crt /usr/local/share/ca-certificates/rootCA.crt > /etc/hydra.crt
    rm /etc/rootCA.key /tmp/hydra.crt
fi

cp /conf/hydra.yml /root/.hydra.yml

lockfile=/.migrated
if [ ! -f $lockfile ]; then 
    hydra migrate sql $DATABASE_URL &&  touch $lockfile
    echo hydra migrate $DATABASE_URL &&  touch $lockfile
    echo "Migrated"
fi

for SCRIPT in /init/*
do
  echo "Running init script: $SCRIPT"
  if [ -x $SCRIPT ] ; then
	  $SCRIPT
  else
	  . $SCRIPT
  fi
done

hydra host --dangerous-force-http

echo "Sleeping for infinity, press Ctrl+C ..."
exec sleep 10000
