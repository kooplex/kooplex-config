#!/bin/bash

case $VERB in
  "install")
    echo "Installing slapd $PROJECT-ldap [$LDAPIP]"
    
    mkdir -p $SRV/ldap/etc/
    mkdir -p $SRV/ldap/var/
    
    LDAPPASS=$(createsecret ldap)
    
    docker $DOCKERARGS create \
      --name $PROJECT-ldap \
      --hostname $PROJECT-ldap \
      --net $PROJECT-net \
      --ip $LDAPIP \
      -p 666:$LDAPPORT \
      -v $SRV/ldap/etc:/etc/ldap \
      -v $SRV/ldap/var:/var/lib/ldap \
      -e SLAPD_PASSWORD="$LDAPPASS" \
      -e SLAPD_CONFIG_PASSWORD="$LDAPPASS" \
      -e SLAPD_DOMAIN=$DOMAIN \
      dinkel/openldap
  ;;
  "start")
    echo "Starting slapd $PROJECT-ldap [$LDAPIP]"
    docker $DOCKERARGS start $PROJECT-ldap
    echo "Waiting for slapd to start"
    # TODO: implement some try-catch logic to wait until
    # slapd comes up
    sleep 10
  ;;
  "init")
    echo "Initializing slapd $PROJECT-ldap [$LDAPIP]"
    
    LDAPPASS=$(getsecret ldap)

    ldapadd -h $LDAPIP -p $LDAPPORT \
      -D cn=admin,$LDAPORG -w "$LDAPPASS" \
      -f units.ldif
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
    rm -R $SRV/ldap/etc/
    rm -R $SRV/ldap/var/
  ;;
esac