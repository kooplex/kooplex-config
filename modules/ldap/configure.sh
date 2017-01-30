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
    
    docker $DOCKERARGS create \
      --name $PROJECT-ldap \
      --hostname $PROJECT-ldap \
      --net $PROJECT-net \
      --ip $LDAPIP \
      -p $LDAPPORT:389 \
      -v $SRV/ldap/etc:/etc/ldap \
      -v $SRV/ldap/var:/var/lib/ldap \
      -e SLAPD_PASSWORD="$LDAPPASS" \
      -e SLAPD_CONFIG_PASSWORD="$LDAPPASS" \
      -e SLAPD_DOMAIN=$DOMAIN \
      $PREFIX-ldap
  ;;
  "start")
    echo "Starting slapd $PROJECT-ldap [$LDAPIP]"
	# TODO: implement logic around it
    echo "AFTER REMOUNT-RESTART: DONT FORGET TO CHECK OWNER: "
    echo "drwxr-xr-x  6 dnsmasq ssl-cert 4096 okt   14 10:42 etc"
    docker $DOCKERARGS start $PROJECT-ldap
    echo "Waiting for slapd to start"
    # TODO: implement some try-catch logic to wait until
    # slapd comes up
    sleep 10
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
    ldapadd -h $LDAPIP -D cn=admin,$LDAPORG -w "$LDAPPASS"

  ;;
  "check")
    echo "Cheking slapd $PROJECT-ldap [$LDAPIP]"
	LDAPPASS=$(getsecret ldap)
	echo "Binding with user cn=admin,$LDAPORG"
	echo "Running test search on docker network"
	ldapsearch -v -H ldap://$LDAPIP:389 -D cn=admin,$LDAPORG -w "$LDAPPASS" -b $LDAPORG | grep cn=admin,$LDAPORG
	echo "Running test search on host machine"
	# TODO: what is local machine?
	ldapsearch -v -H ldap://localhost:$LDAPPORT -D cn=admin,$LDAPORG -w "$LDAPPASS" -b $LDAPORG  | grep cn=admin,$LDAPORG
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