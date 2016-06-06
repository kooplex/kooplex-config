#!/bin/bash

echo "Initializing LDAP $PROJECT-ldap [$LDAPIP]"

# Create basic LDAP configuration

LDAPPASS=$(getsecret ldap)

ldapadd -h $LDAPIP -p $LDAPPORT \
  -D cn=admin,$LDAPORG -w "$LDAPPASS" \
  -f units.ldif
