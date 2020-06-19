#! /bin/sh

# helper
_mkdir () {
    if [ ! -d $1 ] ; then
        mkdir -p $1
        echo "Created folder $1"
    fi
}

# Make sure persistent volumes for services exist
create_pv () {
    for d in $SERVICELOG_DIR $SERVICECONF_DIR $SERVICEDATA_DIR $BUILDDIR; do
        _mkdir $d
    done
    CONF_YAML=$BUILDDIR/pv-service.yaml
    sed -e s,##PREFIX##,$PREFIX, \
        -e s,##KUBE_MASTERNODE##,$KUBE_MASTERNODE, \
        -e s,##SERVICELOG_DIR##,$SERVICELOG_DIR, \
        -e s,##SERVICECONF_DIR##,$SERVICECONF_DIR, \
        -e s,##SERVICEDATA_DIR##,$SERVICEDATA_DIR, \
        $CONFIGDIR/core/pv-service.yaml-template \
        > $CONF_YAML
    kubectl apply -f $CONF_YAML
}

# make sure persistent volume claims exists
create_pvc () {
    CONF_YAML=$BUILDDIR/pvc-service.yaml
    sed -e s,##PREFIX##,$PREFIX, \
        $CONFIGDIR/core/pvc-service.yaml-template \
        > $CONF_YAML
    kubectl apply -f $CONF_YAML
}


# make module build dir
mkdir_build () {
    if [ -z "$MODULE_NAME" ] ; then
        echo "ERROR MODULE_NAME is not set" >&2
        return
    fi
    BUILDMOD_DIR=$BUILDDIR/$MODULE_NAME
    _mkdir $BUILDMOD_DIR
}

# make module config dir
mkdir_svcconf () {
    MODCONF_DIR=$SERVICECONF_DIR/$MODULE_NAME
    _mkdir $MODCONF_DIR
}

# make module log dir
mkdir_svclog () {
    MODLOG_DIR=$SERVICELOG_DIR/$MODULE_NAME
    _mkdir $MODLOG_DIR
}


# make module service data dir
mkdir_svcdata () {
    MODDATA_DIR=$SERVICEDATA_DIR/$MODULE_NAME
    _mkdir $MODDATA_DIR
}


## CA_DIR=$BUILDDIR/CA
## if [ -d $CA_DIR ] ; then
##     echo "$CA_DIR already present; will not generate ca" >&2
## else 
##     echo "generate CA"
##     set -e
##     mkdir $CA_DIR
##     openssl genrsa -out $CA_DIR/rootCA.key 4096
##     openssl req -x509 -new -nodes -key $CA_DIR/rootCA.key -sha256 -days 1024 -subj "/C=HU/ST=BP/L=Budapest/O=KRFT/CN=$OUTERHOST" -out $CA_DIR/rootCA.crt
## fi


#DEPRECATED# # IP address functions
#DEPRECATED# 
#DEPRECATED# ldapquery () {
#DEPRECATED# echo ldapsearch -x -H ldap://${PREFIX}-ldap -D cn=admin,$LDAPORG -b ou=users,$LDAPORG -s one "objectclass=top" -w $LDAPPW
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# replace_slash() {
#DEPRECATED# 	        echo $1 | sed 's/\//\\\//g'
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# 
#DEPRECATED# ip_ip2dec () {
#DEPRECATED#   local a b c d ip=$@
#DEPRECATED#   IFS=. read -r a b c d <<< "$ip"
#DEPRECATED#   printf '%d\n' "$((a * 256 ** 3 + b * 256 ** 2 + c * 256 + d))"
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# ip_dec2ip () {
#DEPRECATED#   local ip dec=$@
#DEPRECATED#   for e in {3..0}
#DEPRECATED#   do
#DEPRECATED#     ((octet = dec / (256 ** e) ))
#DEPRECATED#     ((dec -= octet * 256 ** e))
#DEPRECATED#     ip+=$delim$octet
#DEPRECATED#     delim=.
#DEPRECATED#   done
#DEPRECATED#   printf '%s\n' "$ip"
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# ip_addip () {
#DEPRECATED#   local cidr=$1
#DEPRECATED#   local offset=$2
#DEPRECATED#   local network=`echo "$cidr" | egrep '^[0-9\.]+' -o`
#DEPRECATED#   local netmask=`echo "$cidr" | egrep '[0-9]+$' -o`
#DEPRECATED# 
#DEPRECATED#   A=`ip_ip2dec "$network"`
#DEPRECATED#   B=$offset
#DEPRECATED#   local ip=$((A + B))
#DEPRECATED# 
#DEPRECATED#   ip_dec2ip "$ip"
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# # LDAP functions
#DEPRECATED# 
#DEPRECATED# ldap_ldapconfig() {
#DEPRECATED#     echo "
#DEPRECATED# BASE   $LDAPORG
#DEPRECATED# URI    ldap://$PREFIX-ldap/
#DEPRECATED# 
#DEPRECATED# # TLS certificates (needed for GnuTLS)
#DEPRECATED# TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
#DEPRECATED# "
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# ldap_nsswitchconfig() {
#DEPRECATED#   echo "
#DEPRECATED# passwd:         ldap compat
#DEPRECATED# group:          ldap compat
#DEPRECATED# shadow:         ldap compat
#DEPRECATED# gshadow:        files
#DEPRECATED# 
#DEPRECATED# hosts:          files dns
#DEPRECATED# networks:       files
#DEPRECATED# 
#DEPRECATED# protocols:      db files
#DEPRECATED# services:       db files
#DEPRECATED# ethers:         db files
#DEPRECATED# rpc:            db files
#DEPRECATED# 
#DEPRECATED# netgroup:       nis
#DEPRECATED#   "
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# ldap_nslcdconfig () {
#DEPRECATED# #  LDAPPW=$(getsecret ldap)
#DEPRECATED#   echo "uid nslcd
#DEPRECATED# gid nslcd
#DEPRECATED# 
#DEPRECATED# uri ldap://$PREFIX-ldap/
#DEPRECATED# 
#DEPRECATED# base $LDAPORG
#DEPRECATED# scope subtree
#DEPRECATED# 
#DEPRECATED# binddn cn=admin,$LDAPORG
#DEPRECATED# bindpw $HUBLDAP_PW
#DEPRECATED# #rootpwmoddn cn=admin,$LDAPORG
#DEPRECATED# #rootpwmodpw $HUBLDAP_PW
#DEPRECATED# 
#DEPRECATED# "
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# ldap_fdqn2cn () {
#DEPRECATED#   local aa q fdqn=$@
#DEPRECATED#   IFS=. read -ra aa <<< "$fdqn"
#DEPRECATED#   q=0
#DEPRECATED#   for i in "${aa[@]}"
#DEPRECATED#   do
#DEPRECATED#     if test $q -gt 0
#DEPRECATED#     then
#DEPRECATED#      printf ','
#DEPRECATED#     fi
#DEPRECATED#     printf 'dc=%s' "$i"
#DEPRECATED# 	q=$((q + 1))
#DEPRECATED#   done
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# #ldap_makeconfig () {
#DEPRECATED# #  SVC=$1
#DEPRECATED# #  
#DEPRECATED# #  mkdir -p $SRV/$SVC/etc/ldap
#DEPRECATED# #  printf "$(ldap_ldapconfig)\n\n" > $SRV/$SVC/etc/ldap/ldap.conf
#DEPRECATED# #  printf "$(ldap_nsswitchconfig)\n\n" > $SRV/$SVC/etc/nsswitch.conf
#DEPRECATED# #  printf "$(ldap_nslcdconfig)\n\n" > $SRV/$SVC/etc/nslcd.conf
#DEPRECATED# #  chown root $SRV/$SVC/etc/nslcd.conf
#DEPRECATED# #  chmod 0600 $SRV/$SVC/etc/nslcd.conf
#DEPRECATED# #}
#DEPRECATED# #
#DEPRECATED# #ldap_makebinds () {
#DEPRECATED# #  SVC=$1
#DEPRECATED# #  
#DEPRECATED# #  echo "-v $SRV/$SVC/etc/ldap/ldap.conf:/etc/ldap.conf
#DEPRECATED# #  -v $SRV/$SVC/etc/nslcd.conf:/etc/nslcd.conf
#DEPRECATED# #  -v $SRV/$SVC/etc/nsswitch.conf:/etc/nsswitch.conf
#DEPRECATED# #  -v $SRV/$SVC/etc/jupyter_notebook_config.py:/etc/jupyter_notebook_config.py"
#DEPRECATED# #}
#DEPRECATED# #
#DEPRECATED# #
#DEPRECATED# #ldap_add() {
#DEPRECATED# #  local ldappass=$(getsecret ldap)
#DEPRECATED# #  printf "%s" "$1" | ldapadd -h $LDAPIP -p $LDAPPORT -D "cn=admin,$LDAPORG" -w "$ldappass"
#DEPRECATED# #}
#DEPRECATED# #
#DEPRECATED# #ldap_del() {
#DEPRECATED# #  local ldappass=$(getsecret ldap)
#DEPRECATED# #  echo $LDAPORG
#DEPRECATED# #  printf "uid=%s,ou=users,$LDAPORG " "$1" | ldapdelete -h $LDAPIP -p $LDAPPORT -D "cn=admin,$LDAPORG" -w "$ldappass" -v 
#DEPRECATED# #}
#DEPRECATED# #
#DEPRECATED# #ldap_nextuid() {
#DEPRECATED# #
#DEPRECATED# #  local ldappass=$(getsecret ldap)
#DEPRECATED# #
#DEPRECATED# #  local maxid=`ldapsearch -h $LDAPIP -p $LDAPPORT \
#DEPRECATED# #    -D "cn=admin,$LDAPORG" -w "$ldappass" \
#DEPRECATED# #    -b "ou=users,$LDAPORG" -s one \
#DEPRECATED# #    "objectclass=posixAccount" uidnumber | \
#DEPRECATED# #    grep uidNumber | awk '{ if ($1 != "#") print $2 }' | sort | tail -n 1`
#DEPRECATED# #
#DEPRECATED# #  printf "%d" $((maxid + 1))
#DEPRECATED# #}
#DEPRECATED# #
#DEPRECATED# #ldap_adduser() {
#DEPRECATED# #  local username=$1
#DEPRECATED# #  local firstname=$2
#DEPRECATED# #  local lastname=$3
#DEPRECATED# #  local email=$4
#DEPRECATED# #  local pass=$5
#DEPRECATED# #  local uid=$6
#DEPRECATED# #  
#DEPRECATED# #  echo "Adding LDAP user $firstname $lastname ($username)..."
#DEPRECATED# #
#DEPRECATED# #  ldap_add "dn: uid=$username,ou=users,$LDAPORG
#DEPRECATED# #objectClass: simpleSecurityObject
#DEPRECATED# #objectClass: organizationalPerson
#DEPRECATED# #objectClass: person
#DEPRECATED# #objectClass: top
#DEPRECATED# #objectClass: inetOrgPerson
#DEPRECATED# #objectClass: posixAccount
#DEPRECATED# #objectClass: shadowAccount
#DEPRECATED# #sn: $lastname
#DEPRECATED# #givenName: $firstname
#DEPRECATED# #cn: $username
#DEPRECATED# #displayName: $firstname $lastname
#DEPRECATED# #uidNumber: $uid
#DEPRECATED# #gidNumber: $uid
#DEPRECATED# #loginShell: /bin/bash
#DEPRECATED# #homeDirectory: /home/$username
#DEPRECATED# #mail: $email
#DEPRECATED# #userPassword: $pass
#DEPRECATED# #shadowExpire: -1
#DEPRECATED# #shadowFlag: 0
#DEPRECATED# #shadowWarning: 7
#DEPRECATED# #shadowMin: 8
#DEPRECATED# #shadowMax: 999999
#DEPRECATED# #shadowLastChange: 10877
#DEPRECATED# #"
#DEPRECATED# #
#DEPRECATED# #  ldap_add "dn: cn=$username,ou=groups,$LDAPORG
#DEPRECATED# #objectClass: top
#DEPRECATED# #objectClass: posixGroup
#DEPRECATED# #gidNumber: $uid
#DEPRECATED# #memberUid: $uid
#DEPRECATED# #"
#DEPRECATED# #}
#DEPRECATED# #
#DEPRECATED# #ldap_addgroup() {
#DEPRECATED# #
#DEPRECATED# #  local name=$1
#DEPRECATED# #  local uid=$2
#DEPRECATED# #  
#DEPRECATED# #  local ldappass=$(getsecret ldap)
#DEPRECATED# #  
#DEPRECATED# #  echo "Adding LDAP group $name"
#DEPRECATED# #
#DEPRECATED# #  echo "dn: cn=$name,ou=groups,$LDAPORG
#DEPRECATED# #objectClass: top
#DEPRECATED# #objectClass: posixGroup
#DEPRECATED# #cn: $name
#DEPRECATED# #gidNumber: $uid
#DEPRECATED# #" | \
#DEPRECATED# #  ldapadd -h $LDAPIP -p $LDAPPORT -D "cn=admin,$LDAPORG" -w "$ldappass"
#DEPRECATED# #  
#DEPRECATED# #}
#DEPRECATED# 
#DEPRECATED# # Home functions
#DEPRECATED# 
#DEPRECATED# home_makensfmount() {
#DEPRECATED#   echo "#/bin/sh
#DEPRECATED# echo \"Mounting home...\"
#DEPRECATED# mount -t nfs $PREFIX-home:/exports/home /home"
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# home_makebinds() {
#DEPRECATED#   echo "-v $SRV/home:/home"
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# # Gitlab functions
#DEPRECATED# 
#DEPRECATED# gitlab_exec() {
#DEPRECATED#   docker $DOCKERARGS exec $PREFIX-gitlab /opt/gitlab/bin/gitlab-rails r "$1"
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# gitlab_adduser() {
#DEPRECATED#   local username=$1
#DEPRECATED#   local firstname=$2
#DEPRECATED#   local lastname=$3
#DEPRECATED#   local email=$4
#DEPRECATED#   local pass=$5
#DEPRECATED#   
#DEPRECATED#   echo "Adding Gitlab user $firstname $lastname ($username)..."
#DEPRECATED#   
#DEPRECATED#   gitlab_exec "
#DEPRECATED# u = User.new
#DEPRECATED# u.name = \"$firstname $lastname\"
#DEPRECATED# u.username = \"$username\"
#DEPRECATED# u.password = \"$pass\"
#DEPRECATED# u.email = \"$email\"
#DEPRECATED# u.confirmed_at = Time.now
#DEPRECATED# u.confirmation_token = nil
#DEPRECATED# u.save!
#DEPRECATED# 
#DEPRECATED# i = Identity.new
#DEPRECATED# i.provider = \"ldapmain\"
#DEPRECATED# i.extern_uid = \"uid=$username,ou=users,$LDAPORG\"
#DEPRECATED# i.user = u
#DEPRECATED# i.user_id = u.id
#DEPRECATED# i.save!
#DEPRECATED# "
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# gitlab_deluser() {
#DEPRECATED#   local username=$1
#DEPRECATED# 
#DEPRECATED#   echo "Deleting Gitlab user $username..."
#DEPRECATED#   
#DEPRECATED#   gitlab_exec "
#DEPRECATED#   u = User.find_by_username(\"$username\") 
#DEPRECATED#   u.destroy
#DEPRECATED# "
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# gitlab_resetpass() {
#DEPRECATED#   local username=$1
#DEPRECATED#   local pass=$2
#DEPRECATED#   
#DEPRECATED#   # TODO: find a way to do via API
#DEPRECATED#   
#DEPRECATED#   gitlab_exec "
#DEPRECATED# u = User.find_by_username(\"$username\")
#DEPRECATED# u.password = \"$pass\"
#DEPRECATED# u.save!
#DEPRECATED# "
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# gitlab_makeadmin() {
#DEPRECATED#   local username=$1
#DEPRECATED#   
#DEPRECATED#   # TODO: find a way to do via API
#DEPRECATED#   
#DEPRECATED#   gitlab_exec "
#DEPRECATED# u = User.find_by_username(\"$username\")
#DEPRECATED# u.admin = true
#DEPRECATED# u.save!
#DEPRECATED# "
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# gitlab_session() {
#DEPRECATED#   local username=$1
#DEPRECATED#   local pass=$2
#DEPRECATED#   
#DEPRECATED#   curl -X POST \
#DEPRECATED#     "http://$GITLABIP/gitlab/api/v3/session?login=$username&password=$pass" | \
#DEPRECATED#     grep -oEi '"private_token":"([^"])*"' | cut -d':' -f 2 | cut -d'"' -f 2
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# gitlab_addsshkey() {
#DEPRECATED#   local username=$1
#DEPRECATED#   local pass=$2
#DEPRECATED#   
#DEPRECATED#   local token=$(gitlab_session $username $pass)
#DEPRECATED#   
#DEPRECATED#   curl -X POST -G \
#DEPRECATED#     -H "private-token: $token" \
#DEPRECATED#     --data-urlencode key@$SRV/home/$username/.ssh/gitlab.key.pub \
#DEPRECATED#     "http://$GITLABIP/gitlab/api/v3/user/keys?title=gitlabkey"
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# gitlab_addoauthclient() {
#DEPRECATED#   local name=$1
#DEPRECATED#   local uri=$2
#DEPRECATED#   
#DEPRECATED#   gitlab_exec "
#DEPRECATED# a = Doorkeeper::Application.new
#DEPRECATED# a.name = \"$name\"
#DEPRECATED# a.redirect_uri = \"$uri\"
#DEPRECATED# a.save!
#DEPRECATED# 
#DEPRECATED# print(a.uid, \" \", a.secret, \"\\n\")
#DEPRECATED# "
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# 
#DEPRECATED# reverse() {
#DEPRECATED#   echo "$@" | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }'
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# createsecret() {
#DEPRECATED#   local name=$1
#DEPRECATED#   #openssl rand -base64 32 > $SECRETS/$name.secret
#DEPRECATED#   echo "$DUMMYPASS" > $SECRETS/$name.secret
#DEPRECATED#   cat $SECRETS/$name.secret
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# getsecret() {
#DEPRECATED#   local name=$1
#DEPRECATED#   cat $SECRETS/$name.secret
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# adduser() {
#DEPRECATED# 
#DEPRECATED#     # TODO: replace this with python script
#DEPRECATED# 
#DEPRECATED#   local username=$1
#DEPRECATED#   local firstname=$2
#DEPRECATED#   local lastname=$3
#DEPRECATED#   local email=$4
#DEPRECATED#   local pass=$5
#DEPRECATED#   local uid=$6
#DEPRECATED#   
#DEPRECATED#   if [ -z $uid ]; then
#DEPRECATED#     uid=$(ldap_nextuid)
#DEPRECATED#   fi
#DEPRECATED#   
#DEPRECATED#   echo "Adding new user $username with uid $uid..."
#DEPRECATED#   
#DEPRECATED#   ldap_adduser "$username" "$firstname" "$lastname" "$email" "$pass" "$uid"
#DEPRECATED#   gitlab_adduser "$username" "$firstname" "$lastname" "$email" "$pass"
#DEPRECATED#   
#DEPRECATED#   # Create home directory
#DEPRECATED#   mkdir -p $SRV/home/$username
#DEPRECATED#   
#DEPRECATED# 
#DEPRECATED#   
#DEPRECATED#   # Generate git private key
#DEPRECATED#   SSHKEYPASS=$(getsecret sshkey)
#DEPRECATED#   mkdir -p $SRV/home/$username/.ssh
#DEPRECATED#   rm -f $SRV/home/$username/.ssh/gitlab.key
#DEPRECATED#   #ssh-keygen -N "$SSHKEYPASS" -f $SRV/home/$username/.ssh/gitlab.key
#DEPRECATED#   ssh-keygen -N "" -f $SRV/home/$username/.ssh/gitlab.key
#DEPRECATED# 
#DEPRECATED#   # Register key in Gitlab
#DEPRECATED#   gitlab_addsshkey $username $pass
#DEPRECATED#   
#DEPRECATED#   # Set home owner
#DEPRECATED#   chown -R $uid:$uid $SRV/home/$username
#DEPRECATED#   setfacl -R -m d:u:$uid:rwx $SRV/home/$username
#DEPRECATED# 
#DEPRECATED#   # Set user quota
#DEPRECATED# #  setquota -u $uid $USRQUOTA $USRQUOTA 0 0 $LOOPNO
#DEPRECATED#   
#DEPRECATED#     # Create Data directory which can be accessed through ownCloud
#DEPRECATED#   echo "Initializing OwnCloud folders for  $uid $username"
#DEPRECATED#   PATH_OWNCLOUD=$SRV/ownCloud
#DEPRECATED#   if [ ! -d $PATH_OWNCLOUD ]; then
#DEPRECATED#      mkdir -p $PATH_OWNCLOUD/
#DEPRECATED#   fi
#DEPRECATED#   mkdir -p $PATH_OWNCLOUD/$username/
#DEPRECATED#   mkdir -p $PATH_OWNCLOUD/$username/files/
#DEPRECATED#   chown -R www-data:www-data $PATH_OWNCLOUD/$username/
#DEPRECATED#   mkdir -p $SRV/home/$username/Data
#DEPRECATED#   chown -R www-data:www-data  $SRV/home/$username/Data
#DEPRECATED#   sleep 10
#DEPRECATED#   docker $DOCKERARGS exec $PREFIX-owncloud bash -c "cd /var/www/html/;chown root console.php config/config.php; php ./console.php files:scan --unscanned --all; chown www-data console.php config/config.php"
#DEPRECATED# 
#DEPRECATED# 
#DEPRECATED#   echo "New user created: $uid $username"
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# modifyuser() {
#DEPRECATED#   # TODO: implement
#DEPRECATED# 
#DEPRECATED#   echo Not implemented >&2
#DEPRECATED#   exit 2
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# deleteuser() {
#DEPRECATED#   # TODO: implement
#DEPRECATED#   local username=$1
#DEPRECATED#   
#DEPRECATED#   echo "Deleting LDAP user ($username)..."
#DEPRECATED# 
#DEPRECATED#   ldap_del $username 
#DEPRECATED#   gitlab_deluser $username
#DEPRECATED#   rm -r $SRV/home/$username/
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# resetpass() {
#DEPRECATED#   # TODO: implement
#DEPRECATED# 
#DEPRECATED#   echo Not implemented >&2
#DEPRECATED#   exit 2
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# isindocker() {
#DEPRECATED#   local d=`cat /proc/1/cgroup | grep -e "systemd:/.+"`
#DEPRECATED#   
#DEPRECATED#   if [ -z "$d" ]; then
#DEPRECATED#     echo 0
#DEPRECATED#   else
#DEPRECATED#     echo 1
#DEPRECATED#   fi
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# config() {
#DEPRECATED#   source ${KOOPLEX_DIR}config.sh
#DEPRECATED#   
#DEPRECATED#   KOOPLEXWD=`pwd`
#DEPRECATED#   
#DEPRECATED# #  SRV=$ROOT/$PREFIX
#DEPRECATED# #  SECRETS=$SRV/.secrets
#DEPRECATED# 
#DEPRECATED#   SSHLOC=`which ssh`
#DEPRECATED# 
#DEPRECATED#   ADMINIP=$(ip_addip "$SUBNET" 2)
#DEPRECATED#   
#DEPRECATED#   LDAPIP=$(ip_addip "$SUBNET" 3)
#DEPRECATED#   LDAPORG=$(ldap_fdqn2cn "$LDAPDOMAIN")
#DEPRECATED#   echo $LDAPORG
#DEPRECATED#   LDAPSERV=$PREFIX-ldap
#DEPRECATED#   LDAPPORT=389
#DEPRECATED# 
#DEPRECATED#   HOMEIP=$(ip_addip "$SUBNET" 4)
#DEPRECATED#   
#DEPRECATED#   GITLABIP=$(ip_addip "$SUBNET" 5)
#DEPRECATED#   
#DEPRECATED#   JUPYTERHUBIP=$(ip_addip "$SUBNET" 6)
#DEPRECATED#   
#DEPRECATED#   OWNCLOUDIP=$(ip_addip "$SUBNET" 7)
#DEPRECATED#   
#DEPRECATED#   NOTEBOOKIP=$(ip_addip "$SUBNET" 8)
#DEPRECATED#   
#DEPRECATED#   PROXYIP=$(ip_addip "$SUBNET" 9)
#DEPRECATED#   
#DEPRECATED#   NGINXIP=$(ip_addip "$SUBNET" 16)
#DEPRECATED#   
#DEPRECATED#   HUBIP=$(ip_addip "$SUBNET" 18)
#DEPRECATED#   MONITORIP=$(ip_addip "$SUBNET" 20)
#DEPRECATED#   
#DEPRECATED#   SMTPIP=$(ip_addip "$SUBNET" 25)
#DEPRECATED#   
#DEPRECATED#   MYSQLIP=$(ip_addip "$SUBNET" 19)
#DEPRECATED# 
#DEPRECATED#   MYSQLPASS=$HUBDBPW
#DEPRECATED#   
#DEPRECATED#   GITLABDBIP=$(ip_addip "$SUBNET" 32)
#DEPRECATED# 
#DEPRECATED#   GITLABDBPASS=$GITLABDBPW
#DEPRECATED# 
#DEPRECATED#   DASHBOARDSIP=$(ip_addip "$SUBNET" 21)
#DEPRECATED#   DASHBOARDSDIR=$SRV"/_report"
#DEPRECATED#   
#DEPRECATED# #  DOCKERPORT=${DOCKERARGS##*:}
#DEPRECATED# 
#DEPRECATED#   IPPOOLB=$(ip_addip "$SUBNET" 5121)
#DEPRECATED#   IPPOOLE=$(ip_addip "$SUBNET" 5375) 
#DEPRECATED# 
#DEPRECATED#   PROXYTOKEN=$(createsecret proxy)
#DEPRECATED# 
#DEPRECATED#  
#DEPRECATED# 
#DEPRECATED#   if [ $(isindocker) -eq 1 ]; then
#DEPRECATED#     echo "Process is running inside a docker container."
#DEPRECATED#   else
#DEPRECATED#     echo "Process is running on the host."
#DEPRECATED#   fi
#DEPRECATED# }
#DEPRECATED# 
#DEPRECATED# config
