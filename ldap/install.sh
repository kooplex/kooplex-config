#! /bin/sh
#

IP=$1
LDAPORG=`../fdqn2ldap.sh $2`

LDAPSERV=$PROJECT-ldap
LDAPPORT=389

echo "Installing slapd $PROJECT-ldap [$IP]"

# Initialize LDAP directory with necessary schemas and items

mkdir -p $SRV/ldap/etc/
mkdir -p $SRV/ldap/var/

# Generate LDAP random password
#openssl rand -base64 32 > $SECRETS/ldap.secret
echo "alma" > $SECRETS/ldap.secret
LDAPPASS="`cat $SECRETS/ldap.secret`"
echo $LDAPPASS

# Install and execute docker image

docker run -d \
  --name $PROJECT-ldap \
  --net $PROJECT-net \
  --ip $IP \
  -p 666:$LDAPPORT \
  -v /data/data1/compare/srv/ldap/etc:/etc/ldap \
  -v /data/data1/compare/srv/ldap/var:/var/lib/ldap \
  -e SLAPD_PASSWORD="$LDAPPASS" \
  -e SLAPD_CONFIG_PASSWORD="$LDAPPASS" \
  -e SLAPD_DOMAIN=$DOMAIN \
  dinkel/openldap
  
echo "Waiting for slapd to start"
  
sleep 3

# Create basic configuration

ldapadd -v -h $IP -p $LDAPPORT \
  -D cn=admin,$LDAPORG -w "$LDAPPASS" \
  -f units.ldif

ldapadd -v -h $IP -p $LDAPPORT \
  -D cn=admin,$LDAPORG -w "$LDAPPASS" \
  -f testuser.ldif

ldapadd -v -h $IP -p $LDAPPORT \
  -D cn=admin,$LDAPORG -w "$LDAPPASS" \
  -f testgroup.ldif

