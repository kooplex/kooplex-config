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
  --hostname $PROJECT-ldap \
  --net $PROJECT-net \
  --ip $LDAPIP \
  -p $HOSTLDAPPORT:$LDAPPORT \
  -v $SRV/ldap/etc:/etc/ldap \
  -v $SRV/srv/ldap/var:/var/lib/ldap \
  -e SLAPD_PASSWORD="$LDAPPASS" \
  -e SLAPD_CONFIG_PASSWORD="$LDAPPASS" \
  -e SLAPD_DOMAIN=$DOMAIN \
  dinkel/openldap
  
echo "Waiting for slapd to start"
  
sleep 3
