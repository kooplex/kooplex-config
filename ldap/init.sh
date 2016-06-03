#! /bin/sh
#
# Initialize LDAP directory with necessary schemas and items

$LDAPSERV compare-ldap
$LDAPPORT 389
$LDAPORG dc=compare,dc=vo,dc=elte,dc=hu

ldapadd -v -h LDAPSERV compare-ldap -p LDAPPORT -D cn=admin,$LDAPORG -W -f units.ldif
ldapadd -v -h LDAPSERV compare-ldap -p LDAPPORT -D cn=admin,$LDAPORG -W -f testuser.ldif
ldapadd -v -h LDAPSERV compare-ldap -p LDAPPORT -D cn=admin,$LDAPORG -W -f testgroup.ldif