#! /bin/sh

# IP address functions

ip_ip2dec () {
  local a b c d ip=$@
  IFS=. read -r a b c d <<< "$ip"
  printf '%d\n' "$((a * 256 ** 3 + b * 256 ** 2 + c * 256 + d))"
}

ip_dec2ip () {
  local ip dec=$@
  for e in {3..0}
  do
    ((octet = dec / (256 ** e) ))
    ((dec -= octet * 256 ** e))
    ip+=$delim$octet
    delim=.
  done
  printf '%s\n' "$ip"
}

ip_addip () {
  local cidr=$1
  local offset=$2
  local network=`echo "$cidr" | egrep '^[0-9\.]+' -o`
  local netmask=`echo "$cidr" | egrep '[0-9]+$' -o`

  A=`ip_ip2dec "$network"`
  B=$offset
  local ip=$((A + B))

  ip_dec2ip "$ip"
}

# MYSQL functions

mysql_exec() {
  MYSQLPASS=$(getsecret mysql)
  
  if [ $# == 1 ]; then
	mysql -h $MYSQLIP -u root -p"$MYSQLPASS" -e "$1"
  else
    mysql -h $MYSQLIP -u root -p"$MYSQLPASS" -D"$1" -e "$2"
  fi
}

# LDAP functions

ldap_ldapconfig() {
  echo "
BASE   $LDAPORG
URI    ldap://$PROJECT-ldap/

# TLS certificates (needed for GnuTLS)
TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
"
}

ldap_nsswitchconfig() {
  echo "
passwd:         ldap compat
group:          ldap compat
shadow:         ldap compat
gshadow:        files

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
  "
}

ldap_nslcdconfig () {
  LDAPPASS=$(getsecret ldap)
  echo "uid nslcd
gid nslcd

uri ldap://$PROJECT-ldap/

base $LDAPORG
scope subtree

binddn cn=admin,$LDAPORG
bindpw $LDAPPASS
rootpwmoddn cn=admin,$LDAPORG
rootpwmodpw $LDAPPASS

"
}

ldap_makeconfig () {
  SVC=$1
  
  mkdir -p $SRV/$SVC/etc/ldap
  printf "$(ldap_ldapconfig)\n\n" > $SRV/$SVC/etc/ldap/ldap.conf
  printf "$(ldap_nsswitchconfig)\n\n" > $SRV/$SVC/etc/nsswitch.conf
  printf "$(ldap_nslcdconfig)\n\n" > $SRV/$SVC/etc/nslcd.conf
  chown root $SRV/$SVC/etc/nslcd.conf
  chmod 0600 $SRV/$SVC/etc/nslcd.conf
}

ldap_makebinds () {
  SVC=$1
  
  echo "-v $SRV/$SVC/etc/ldap/ldap.conf:/etc/ldap.conf
  -v $SRV/$SVC/etc/nslcd.conf:/etc/nslcd.conf
  -v $SRV/$SVC/etc/nsswitch.conf:/etc/nsswitch.conf
  -v $SRV/$SVC/etc/jupyter_notebook_config.py:/etc/jupyter_notebook_config.py"
}

ldap_fdqn2cn () {
  local aa q fdqn=$@
  IFS=. read -ra aa <<< "$fdqn"
  q=0
  for i in "${aa[@]}"
  do
    if test $q -gt 0
    then
     printf ','
    fi
    printf 'dc=%s' "$i"
	q=$((q + 1))
  done
}

ldap_add() {
  local ldappass=$(getsecret ldap)
  printf "%s" "$1" | ldapadd -h $LDAPIP -D "cn=admin,$LDAPORG" -w "$ldappass"
}

ldap_del() {
  local ldappass=$(getsecret ldap)
  echo $LDAPORG
  printf "uid=%s,ou=users,$LDAPORG " "$1" | ldapdelete -h $LDAPIP -D "cn=admin,$LDAPORG" -w "$ldappass" -v 
}

ldap_nextuid() {

  local ldappass=$(getsecret ldap)

  local maxid=`ldapsearch -h $LDAPIP \
    -D "cn=admin,$LDAPORG" -w "$ldappass" \
    -b "ou=users,$LDAPORG" -s one \
    "objectclass=posixAccount" uidnumber | \
    grep uidNumber | awk '{ if ($1 != "#") print $2 }' | sort | tail -n 1`

  printf "%d" $((maxid + 1))
}

ldap_adduser() {
  local username=$1
  local firstname=$2
  local lastname=$3
  local email=$4
  local pass=$5
  local uid=$6
  
  echo "Adding LDAP user $firstname $lastname ($username)..."

  ldap_add "dn: uid=$username,ou=users,$LDAPORG
objectClass: simpleSecurityObject
objectClass: organizationalPerson
objectClass: person
objectClass: top
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
sn: $lastname
givenName: $firstname
cn: $username
displayName: $firstname $lastname
uidNumber: $uid
gidNumber: $uid
loginShell: /bin/bash
homeDirectory: /home/$username
mail: $email
userPassword: $pass
shadowExpire: -1
shadowFlag: 0
shadowWarning: 7
shadowMin: 8
shadowMax: 999999
shadowLastChange: 10877
"

  ldap_add "dn: cn=$username,ou=groups,$LDAPORG
objectClass: top
objectClass: posixGroup
gidNumber: $uid
memberUid: $uid
"
}

ldap_addgroup() {

  local name=$1
  local uid=$2
  
  local ldappass=$(getsecret ldap)
  
  echo "Adding LDAP group $name"

  echo "dn: cn=$name,ou=groups,$LDAPORG
objectClass: top
objectClass: posixGroup
cn: $name
gidNumber: $uid
" | \
  ldapadd -h $LDAPIP -D "cn=admin,$LDAPORG" -w "$ldappass"
  
}

# Home functions

home_makensfmount() {
  echo "#/bin/sh
echo \"Mounting home...\"
mount -t nfs $PROJECT-home:/exports/home /home"
}

home_makebinds() {
  echo "-v $SRV/home:/home"
}

# Gitlab functions

gitlab_exec() {
  docker $DOCKERARGS exec $PROJECT-gitlab /opt/gitlab/bin/gitlab-rails r "$1"
}

gitlab_adduser() {
  local username=$1
  local firstname=$2
  local lastname=$3
  local email=$4
  local pass=$5
  
  echo "Adding Gitlab user $firstname $lastname ($username)..."
  
  gitlab_exec "
u = User.new
u.name = \"$firstname $lastname\"
u.username = \"$username\"
u.password = \"$pass\"
u.email = \"$email\"
u.confirmed_at = Time.now
u.confirmation_token = nil
u.save!

i = Identity.new
i.provider = \"ldapmain\"
i.extern_uid = \"uid=$username,ou=users,$LDAPORG\"
i.user = u
i.user_id = u.id
i.save!
"
}

gitlab_deluser() {
  local username=$1

  echo "Deleting Gitlab user $username..."
  
  gitlab_exec "
  u = User.find_by_username(\"$username\") 
  u.destroy
"
}

gitlab_resetpass() {
  local username=$1
  local pass=$2
  
  # TODO: find a way to do via API
  
  gitlab_exec "
u = User.find_by_username(\"$username\")
u.password = \"$pass\"
u.save!
"
}

gitlab_makeadmin() {
  local username=$1
  
  # TODO: find a way to do via API
  
  gitlab_exec "
u = User.find_by_username(\"$username\")
u.admin = true
u.save!
"
}

gitlab_session() {
  local username=$1
  local pass=$2
  
  curl -X POST \
    "http://$GITLABIP/gitlab/api/v3/session?login=$username&password=$pass" | \
    grep -oEi '"private_token":"([^"])*"' | cut -d':' -f 2 | cut -d'"' -f 2
}

gitlab_addsshkey() {
  local username=$1
  local pass=$2
  
  local token=$(gitlab_session $username $pass)
  
  curl -X POST -G \
    -H "private-token: $token" \
    --data-urlencode key@$SRV/home/$username/.ssh/gitlab.key.pub \
    "http://$GITLABIP/gitlab/api/v3/user/keys?title=gitlabkey"
}

gitlab_addoauthclient() {
  local name=$1
  local uri=$2
  
  gitlab_exec "
a = Doorkeeper::Application.new
a.name = \"$name\"
a.redirect_uri = \"$uri\"
a.save!

print(a.uid, \" \", a.secret, \"\\n\")
"
}

getverb() {
  echo $1
}

getmodules() {
  if [ $# -lt 2 ] || [ "$2" = "all" ]; then
    echo "$SYSMODULES $MODULES"
  elif [ "$2" = "sys" ]; then
    echo "$SYSMODULES"
  else
    local args=($@)
    echo "${args[@]:1}"
  fi
}

reverse() {
  echo "$@" | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }'
}

createsecret() {
  local name=$1
  local fn=$SECRETS/$name.secret
  
  if [ ! -f $fn ]; then
    mkdir -p $SECRETS
    if [ -n "$DUMMYPASS" ]; then
      echo "$DUMMYPASS" > $fn
    else
      openssl rand -base64 32 > $fn
    fi
  fi
  cat $fn
}

getsecret() {
  local name=$1
  cat $SECRETS/$name.secret
}

adduser() {

  # TODO: replace this with python script and run from admin container

  local username=$1
  local firstname=$2
  local lastname=$3
  local email=$4
  local pass=$5
  local uid=$6
  
  if [ -z $uid ]; then
    uid=$(ldap_nextuid)
  fi
  
  echo "Adding new user $username with uid $uid..."
  
  # Create home directory and subdirectories for owncloud
  mkdir -p $SRV/home/$username/
  chown -R $uid:$uid $SRV/home/$username
  
  mkdir -p $SRV/home/$username/Data/
  chown -R $uid:$OWNCLOUDGRP $SRV/home/$username/Data
  chmod -R g+w $SRV/home/$username/Data
  
  setfacl -R -m d:u:$uid:rwx $SRV/home/$username
  setfacl -R -m d:g:$uid:rwx $SRV/home/$username
  setfacl -R -m d:u:$OWNCLOUDUSR:rwx $SRV/home/$username/Data
  setfacl -R -m d:g:$OWNCLOUDGRP:rwx $SRV/home/$username/Data
      
  # Create directories for owncloud and grant access to www-data
  
  mkdir -p $SRV/owncloud/data/$username/
  mkdir -p $SRV/owncloud/data/$username/files
  mkdir -p $SRV/owncloud/data/$username/cache
  chown -R $OWNCLOUDUSR:$OWNCLOUDGRP $SRV/owncloud/data/$username/
  chmod u-w $SRV/owncloud/data/$username/files
  
  # Set user quota
  echo $uid:/exports/home/$username >> $SRV/nfs/etc/projects
  echo $username:$uid >> $SRV/nfs/etc/projid
  docker $DOCKERARGS exec -ti $PROJECT-nfs xfs_quota -x -c "project -s $username" /exports/home
  
  # Generate git private key
  SSHKEYPASS=$(getsecret sshkey)
  mkdir -p $SRV/home/$username/.ssh
  rm -f $SRV/home/$username/.ssh/gitlab.key
  ssh-keygen -N "$SSHKEYPASS" -f $SRV/home/$username/.ssh/gitlab.key
  
  ldap_adduser "$username" "$firstname" "$lastname" "$email" "$pass" "$uid"
  gitlab_adduser "$username" "$firstname" "$lastname" "$email" "$pass"

  # Register key in Gitlab
  gitlab_addsshkey $username $pass

  echo "New user created: $uid $username"
}

modifyuser() {
  # TODO: implement

  echo Not implemented >&2
  exit 2
}

deleteuser() {
  # TODO: implement
  local username=$1
  
  echo "Deleting LDAP user ($username)..."

  ldap_del $username 
  gitlab_deluser $username
  rm -r $SRV/home/$username/
}

resetpass() {
  # TODO: implement

  echo Not implemented >&2
  exit 2
}

isindocker() {
  local d=`cat /proc/1/cgroup | grep -e "systemd:/.+"`
  
  if [ -z "$d" ]; then
    echo 0
  else
    echo 1
  fi
}

config() {
  source config.sh
  
  KOOPLEXWD=`pwd`
  
  SRV=$ROOT/$PROJECT
  SECRETS=$SRV/.secrets

  SSHLOC=`which ssh`

  ADMINIP=$(ip_addip "$SUBNET" 2)
  
  LDAPIP=$(ip_addip "$SUBNET" 3)
  LDAPORG=$(ldap_fdqn2cn "$DOMAIN")
  LDAPSERV=$PROJECT-ldap

  NFSIP=$(ip_addip "$SUBNET" 4)
  
  # TODO: we'll have one home volume container per host so need a pool of IPs
  HOMEIP=$(ip_addip "$SUBNET" 100)
  
  GITLABIP=$(ip_addip "$SUBNET" 5)
  
  JUPYTERHUBIP=$(ip_addip "$SUBNET" 6)
  
  OWNCLOUDIP=$(ip_addip "$SUBNET" 7)
  OWNCLOUDPATH=$SRV/owncloud
  
  NOTEBOOKIP=$(ip_addip "$SUBNET" 8)
  
  PROXYIP=$(ip_addip "$SUBNET" 9)
  
  NGINXIP=$(ip_addip "$SUBNET" 16)
  
  HUBIP=$(ip_addip "$SUBNET" 18)
  
  MYSQLIP=$(ip_addip "$SUBNET" 19)

  DASHBOARDSIP=$(ip_addip "$SUBNET" 21)
  DASHBOARDSDIR=$SRV"/dashboards"
  
  DOCKERPORT=${DOCKERARGS##*:}

  # Notebook IP pool
  # TODO: rename variables to something meaningful
  IPPOOLB=$(ip_addip "$SUBNET" 5121)
  IPPOOLE=$(ip_addip "$SUBNET" 5375) 

  PROXYTOKEN=$(createsecret proxy)

  if [ $(isindocker) -eq 1 ]; then
    echo "Process is running inside a docker container."
  else
    echo "Process is running on the host."
  fi
}

config
