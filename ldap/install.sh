#! /bin/sh

echo "Installing slapd $PROJECT-ldap [$LDAPIP]"

# Initialize LDAP directory with necessary schemas and items

mkdir -p $SRV/ldap/etc/
mkdir -p $SRV/ldap/var/

# Generate LDAP random password
LDAPPASS=$(createsecret ldap)

# Install and execute docker image

docker run -d \
  --name $PROJECT-ldap \
  --net $PROJECT-net \
  --ip $LDAPIP \
  -p 666:$LDAPPORT \
  -v /data/data1/compare/srv/ldap/etc:/etc/ldap \
  -v /data/data1/compare/srv/ldap/var:/var/lib/ldap \
  -e SLAPD_PASSWORD="$LDAPPASS" \
  -e SLAPD_CONFIG_PASSWORD="$LDAPPASS" \
  -e SLAPD_DOMAIN=$DOMAIN \
  dinkel/openldap
  
echo "Waiting for slapd to start"
  
sleep 3