#!/bin/bash

case $VERB in
  "build")
    echo "Building image kooplex-ldap"
    docker $DOCKERARGS build -t kooplex-ldap  .
  ;;
  "install")
    echo "Installing slapd $PROJECT-ldap [$LDAPIP]"
    
    LDAPPASS=$(getsecret ldap)
    
    mkdir -p $SRV/ldap/etc/
    mkdir -p $SRV/ldap/var/
    chown -R root $SRV/ldap
    chmod -R 755 $SRV/ldap

    cont_exist=`docker $DOCKERARGS ps -a | grep $PROJECT-ldap | awk '{print $2}'`
    if [ ! $cont_exist ]; then
    docker $DOCKERARGS create \
      --name $PROJECT-ldap \
      --hostname $PROJECT-ldap \
      --net $PROJECT-net \
      --ip $LDAPIP \
      -p 666:$LDAPPORT \
      --log-opt max-size=1m --log-opt max-file=3 \
      -v /etc/localtime:/etc/localtime:ro \
      -v $SRV/ldap/etc:/etc/ldap \
      -v $SRV/ldap/var:/var/lib/ldap \
      -e SLAPD_PASSWORD="$LDAPPASS" \
      -e SLAPD_CONFIG_PASSWORD="$LDAPPASS" \
      -e SLAPD_DOMAIN=$LDAPDOMAIN \
      kooplex-ldap 
    else
     echo "$PROJECT-ldap is already installed"
    fi      

  ;;
  "start")
    echo "Starting slapd $PROJECT-ldap [$LDAPIP]"
    docker $DOCKERARGS start $PROJECT-ldap
    echo "Waiting for slapd to start"
    # TODO: implement some try-catch logic to wait until
    # slapd comes up
    sleep 1
  ;;
  "init")
    echo "Initializing slapd $PROJECT-ldap [$LDAPIP]"
    
    LDAPPASS=$(getsecret ldap)

    echo "dn: ou=users,$LDAPORG
objectClass: organizationalUnit
objectClass: top
ou: people

dn: ou=groups,$LDAPORG
objectClass: organizationalUnit
objectClass: top
ou: groups" | \
    ldapadd -h $LDAPIP -p $LDAPPORT \
      -D cn=admin,$LDAPORG -w "$LDAPPASS" \

  ;;
  "stop")
    echo "Stopping slapd $PROJECT-ldap [$LDAPIP]"
    docker $DOCKERARGS stop $PROJECT-ldap
  ;;
  "remove")
    echo "Removing slapd $PROJECT-ldap [$LDAPIP]"
    docker $DOCKERARGS rm $PROJECT-ldap
  ;;
  "purge")
    echo "Purging slapd $PROJECT-ldap [$LDAPIP]"
    rm -R -f $SRV/ldap
    rm -R -f $SRV/ldap
  ;;
  "clean")
    echo "Cleaning image kooplex-ldap"
    docker $DOCKERARGS rmi kooplex-ldap
  ;;
esac