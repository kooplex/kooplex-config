#! /bin/bash

UNAME=$1

#FIXME: HARDCODED
LDAP_DOMAIN="cn=admin,dc=kooplex,Dc=complex,dc=elte,dc=hu"
LDAP_PORT=389
LDAP_BIND="ou=users,dc=kooplex,dc=complex,dc=elte,dc=hu"
LDAP_PW="almafa137"
###################################

GIT_CONF=/home/$1/.gitconfig

if [ -f $GIT_CONF ] ; then
  echo "$GIT_CONF exists"
  exit 0
fi

CMD="ldapsearch -LLL -h kooplex-ldap -p $LDAP_PORT -D "$LDAP_DOMAIN" -b "$LDAP_BIND" -w $LDAP_PW  -s one  "uid=$UNAME" displayName mail"

MAIL=$( $CMD | awk '/^mail: / { print $2 }' )
NAME=$( $CMD | awk '/^displayName: / { n = $2; for (i = 3; i <= NF; i++) { n = n" "$i; print n } }')

cat > $GIT_CONF << EOF
[user]
        name = $NAME
        email = $MAIL
[push]
        default = matching
EOF

IDS=$(getent passwd $UNAME | awk -v FS=":" '{ print $3":"$4 }' )

chown $IDS $GIT_CONF

echo "$GIT_CONF created for $UNAME"
