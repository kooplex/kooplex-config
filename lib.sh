#! /bin/sh


# registering to NGINX 
register_nginx() {

 ### THAT IS UGLY. Kubernetes will sort it out
 NGINX_IP=`IP=$(docker $DOKERARGS inspect ${PREFIX}-nginx | grep "\"IPAddress\": \"172"); echo ${IP%*,} | sed -e 's/"//g' | awk '{print $2}'`
 MODULE_NAME=$1
 echo "Installing containers of ${PREFIX}-${MODULE_NAME}"

 sed -e "s/##PREFIX##/$PREFIX/" \
     -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
     -e "s/##MODULE_NAME##/${MODULE_NAME}/" \
     -e "s/##OUTERHOST##/${OUTERHOST}/" nginx-conf/nginx-conf-template | curl -u ${NGINX_API_USER}:${NGINX_API_PW}\
        ${NGINX_IP}:5000/api/new/${MODULE_NAME} -H "Content-Type: text/plain" -X POST --data-binary @-
}

unregister_nginx() {
 ### THAT IS UGLY. Kubernetes will sort it out
 NGINX_IP=`IP=$(docker $DOKERARGS inspect ${PREFIX}-nginx | grep "\"IPAddress\": \"172"); echo ${IP%*,} | sed -e 's/"//g' | awk '{print $2}'`
 MODULE_NAME=$1
 echo "Uninstalling containers of ${PREFIX}-${MODULE_NAME}"
 curl -u ${NGINX_API_USER}:${NGINX_API_PW} ${NGINX_IP}:5000/api/remove/${MODULE_NAME}
}

# registering to HYDRA
register_hydra() {
 HYDRA_IP=`IP=$(docker $DOCKERARGS inspect ${PREFIX}-hydra | grep "\"IPAddress\": \"172"); echo ${IP%*,} | sed -e 's/"//g' | sed 's/,//g' | awk '{print $2}'`
 MODULE_NAME=$1
 echo "Installing containers of ${PREFIX}-${MODULE_NAME}"

 sed -e "s/##PREFIX##/$PREFIX/" \
     -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" \
     -e "s/##OUTERHOST##/${OUTERHOST}/g" hydra-conf/hydra-client-template | curl -u ${HYDRA_API_USER}:${HYDRA_API_PW}\
           ${HYDRA_IP}:5000/api/new-client/${PREFIX}-${MODULE_NAME} -H "Content-Type: application/json" -X POST --data-binary @-

 sed -e "s/##PREFIX##/$PREFIX/" \
     -e "s/##OUTERHOST##/${OUTERHOST}/g" hydra-conf/hydra-policy-template | curl -u ${HYDRA_API_USER}:${HYDRA_API_PW}\
        ${HYDRA_IP}:5000/api/new-policy/${PREFIX}-${MODULE_NAME} -H "Content-Type: application/json" -X POST --data-binary @-
}

unregister_hydra() {
 HYDRA_IP=`IP=$(docker $DOCKERARGS inspect ${PREFIX}-hydra | grep "\"IPAddress\": \"172"); echo ${IP%*,} | sed -e 's/"//g' | sed 's/,//g' | awk '{print $2}'`
 MODULE_NAME=$1
 echo "Uninstalling containers of ${PREFIX}-${MODULE_NAME}"
 curl -X DELETE -u ${HYDRA_API_USER}:${HYDRA_API_PW} ${HYDRA_IP}:5000/api/remove/${PREFIX}-${MODULE_NAME}
}
# IP address functions

ldapquery () {
echo ldapsearch -x -H ldap://${PREFIX}-ldap -D cn=admin,$LDAPORG -b ou=users,$LDAPORG -s one "objectclass=top" -w $LDAPPW
}


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

# LDAP functions

ldap_ldapconfig() {
    echo "
BASE   $LDAPORG
URI    ldap://$PREFIX-ldap/

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
#  LDAPPW=$(getsecret ldap)
  echo "uid nslcd
gid nslcd

uri ldap://$PREFIX-ldap/

base $LDAPORG
scope subtree

binddn cn=admin,$LDAPORG
bindpw $HUBLDAP_PW
#rootpwmoddn cn=admin,$LDAPORG
#rootpwmodpw $HUBLDAP_PW

"
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

# Home functions

home_makensfmount() {
  echo "#/bin/sh
echo \"Mounting home...\"
mount -t nfs $PREFIX-home:/exports/home /home"
}

home_makebinds() {
  echo "-v $SRV/home:/home"
}

# Gitlab functions

gitlab_exec() {
  docker $DOCKERARGS exec $PREFIX-gitlab /opt/gitlab/bin/gitlab-rails r "$1"
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


reverse() {
  echo "$@" | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }'
}

createsecret() {
  local name=$1
  mkdir -p $SECRETS
  #openssl rand -base64 32 > $SECRETS/$name.secret
  echo "$DUMMYPASS" > $SECRETS/$name.secret
  cat $SECRETS/$name.secret
}

getsecret() {
  local name=$1
  cat $SECRETS/$name.secret
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
  source ${KOOPLEX_DIR}config.sh
  
  KOOPLEXWD=`pwd`
  
#  SRV=$ROOT/$PREFIX
#  SECRETS=$SRV/.secrets

  SSHLOC=`which ssh`

  ADMINIP=$(ip_addip "$SUBNET" 2)
  
  LDAPIP=$(ip_addip "$SUBNET" 3)
  LDAPORG=$(ldap_fdqn2cn "$LDAPDOMAIN")
  LDAPSERV=$PREFIX-ldap
  LDAPPORT=389

  HOMEIP=$(ip_addip "$SUBNET" 4)
  
  GITLABIP=$(ip_addip "$SUBNET" 5)
  
  JUPYTERHUBIP=$(ip_addip "$SUBNET" 6)
  
  OWNCLOUDIP=$(ip_addip "$SUBNET" 7)
  
  NOTEBOOKIP=$(ip_addip "$SUBNET" 8)
  
  PROXYIP=$(ip_addip "$SUBNET" 9)
  
  NGINXIP=$(ip_addip "$SUBNET" 16)
  
  HUBIP=$(ip_addip "$SUBNET" 18)
  MONITORIP=$(ip_addip "$SUBNET" 20)
  
  SMTPIP=$(ip_addip "$SUBNET" 25)
  
  MYSQLIP=$(ip_addip "$SUBNET" 19)

  MYSQLPASS=$HUBDBPW
  
  GITLABDBIP=$(ip_addip "$SUBNET" 32)

  GITLABDBPASS=$GITLABDBPW

  DASHBOARDSIP=$(ip_addip "$SUBNET" 21)
  DASHBOARDSDIR=$SRV"/_report"
  
#  DOCKERPORT=${DOCKERARGS##*:}

  IPPOOLB=$(ip_addip "$SUBNET" 5121)
  IPPOOLE=$(ip_addip "$SUBNET" 5375) 

  PROXYTOKEN=$(createsecret proxy)

 

#  if [ $(isindocker) -eq 1 ]; then
#    echo "Process is running inside a docker container."
#  else
#    echo "Process is running on the host."
#  fi
}

config
