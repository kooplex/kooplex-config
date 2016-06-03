#! /bin/sh
#
# Initialize LDAP directory with necessary schemas and items

# LDAP container
export $LDAPID = $ROOTIP.2
export $LDAPHOST compare-ldap
export $LDAPPORT 389
export $LDAPORG dc=compare,dc=vo,dc=elte,dc=hu

# LDAP random password
openssl rand -base64 32 > $SECRETS/ldap.secret
export $LDAPPASS = `cat $SECRETS/ldap.secret`

# Create and start docker container

docker run -d --net testnet -p 666:389 --name compare-ldap -v /data/data1/compare/srv/ldap/etc:/etc/ldap -v /data/data1/compare/srv/ldap/var:/var/lib/ldap -e SLAPD_PASSWORD=alma -e SLAPD_CONFIG_PASSWORD=alma -e SLAPD_DOMAIN=compare.vo.elte.hu dinkel/openldap

# Create basic configuration

ldapadd -v -h LDAPSERV compare-ldap -p LDAPPORT -D cn=admin,$LDAPORG -W -f units.ldif
ldapadd -v -h LDAPSERV compare-ldap -p LDAPPORT -D cn=admin,$LDAPORG -W -f testuser.ldif
ldapadd -v -h LDAPSERV compare-ldap -p LDAPPORT -D cn=admin,$LDAPORG -W -f testgroup.ldif