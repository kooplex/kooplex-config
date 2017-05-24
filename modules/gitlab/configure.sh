#!/bin/bash

case $VERB in
  "build")
     LDAPPASS=$(getsecret ldap)
    
    mkdir -p $SRV/gitlab/etc
    mkdir -p $SRV/gitlab/log
    mkdir -p $SRV/gitlab/opt
    chown -R root $SRV/gitlab
    chmod -R 755 $SRV/gitlab
    
    GITLABRB=$SRV/gitlab/etc/gitlab.rb
    cat << EOF > $GITLABRB 
external_url = 'http://$OUTERHOST/gitlab'

gitlab_rails['gitlab_email_from'] = '$EMAIL'
gitlab_rails['gitlab_email_display_name'] = '$PROJECT gitlab'
gitlab_rails['gitlab_email_reply_to'] = '$EMAIL'
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = $SMTP
gitlab_rails['smtp_port'] = 25
#gitlab_rails['smtp_authentication'] = "plain"
#gitlab_rails['smtp_domain'] = "elte.hu"


gitlab_rails['gitlab_signup_enabled'] = false
gitlab_rails['gitlab_signin_enabled'] = false

gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # remember to close this block with 'EOS' below
  main:
    label: 'LDAP'
    host: '$PROJECT-ldap'
    port: 389
    uid: 'uid'
    method: 'plain'
    bind_dn: 'cn=admin,$LDAPORG'
    password: '$LDAPPASS'
    active_directory: false
    allow_username_or_email_login: false
    block_auto_created_users: false
    base: 'ou=users,$LDAPORG'
    user_filter: '(objectClass=posixAccount)'
    attributes:
      username: ['uid', 'userid', 'sAMAccountName']
      email:    ['mail', 'email', 'userPrincipalName']
      name:       'cn'
      first_name: 'givenName'
      last_name:  'sn'
EOS

logging['logrotate_frequency'] = "daily" # rotate logs daily
logging['logrotate_size'] = nil # do not rotate by size by default
logging['logrotate_rotate'] = 30 # keep 30 rotated logs
logging['logrotate_compress'] = "compress" # see 'man logrotate'
logging['logrotate_method'] = "copytruncate" # see 'man logrotate'
logging['logrotate_postrotate'] = nil # no postrotate command by default
logging['logrotate_dateformat'] = nil # use date extensions for rotated files rather than numbers 
logging['log_level'] = 'ERROR'
mattermost['log_console_level'] = 'ERROR' 
mattermost['log_file_level'] = 'ERROR'
registry['log_level'] = 'error'
gitlab_shell['log_level'] = 'ERROR'

EOF

 ;;
  "install")
    echo "Installing gitlab $PROJECT-gitlab [$GITLABIP]"

 
#TO DISABLE LOG!!!!!!
# chmod 0000 -R  $SRV/gitlab/log/nginx/	
# chmod 0000 -R  $SRV/gitlab/log/gitlab-workhorse/*	
# rm  $SRV/gitlab/log/nginx/*
# rm  $SRV/gitlab/log/gitlab-workhorse/*


cont_exist=`docker $DOCKERARGS ps | grep $PROJECT-gitlab | awk '{print $2}'`
    if [ ! $cont_exist ]; then
    docker $DOCKERARGS create \
      --name $PROJECT-gitlab \
      --hostname $PROJECT-gitlab \
      --sysctl net.core.somaxconn=1024 \
      --ulimit sigpending=62793 \
      --ulimit nproc=131072 \
      --ulimit nofile=60000 \
      --ulimit core=0 \
      --net $PROJECT-net \
      --ip $GITLABIP \
      --log-opt max-size=1m --log-opt max-file=3 \
      -v /etc/localtime:/etc/localtime:ro \
      -v $SRV/gitlab/etc:/etc/gitlab \
      -v $SRV/gitlab/log:/var/log/gitlab \
      -v $SRV/gitlab/opt:/var/opt/gitlab \
      gitlab/gitlab-ce
    else
     echo "$PROJECT-gitlab is already installed"
    fi      
  ;;
  "start")
    echo "Starting gitlab $PROJECT-gitlab [$GITLABIP]"
    #AFTER MODIFICATION OF gitlab.rb
echo "chmod 0755 -R $SRV/gitlab/etc/"
echo "chmod 0400 -R $SRV/gitlab/etc/ssh*_key"
echo "chmod 2770 -R $SRV/gitlab/opt/git-data/repositories/"
echo "chmod a+w -R $SRV/gitlab/opt/prometheus/"
    
    docker $DOCKERARGS start $PROJECT-gitlab
    echo "Waiting X seconds for the Gitlab application to start... Check whether $PROTOCOL://$OUTERHOST/gitlab shows the sign in page!"
    
    echo "docker exec -it $PROJECT-gitlab update-permissions"
#    sleep 30
  ;;
  "init")
    echo "Initializing gitlab $PROJECT-gitlab [$GITLABIP]"
        
    echo "Creating Gitlab admin user..."
    
    # Generate Gitlab and keyfile random password
    GITLABPASS=$(createsecret gitlab)
    SSHKEYPASS=$(createsecret sshkey)

    adduser gitlabadmin Gitlab Admin "admin@$INNERHOSTNAME" "$GITLABPASS" 10001
    gitlab_makeadmin gitlabadmin

    # TODO: disable standard login and self-registration via Gitlab
    
    echo "Securing host keys..."
    chmod 600 $SRV/gitlab/etc/ssh_host_*
  ;;
  "stop")
    echo "Stopping gitlab $PROJECT-gitlab [$GITLABIP]"
    docker $DOCKERARGS stop $PROJECT-gitlab
  ;;
  "remove")
    echo "Removing gitlab $PROJECT-gitlab [$GITLABIP]"
    docker $DOCKERARGS rm $PROJECT-gitlab
  ;;
    "clean")
    echo "Removing gitlab image gitlab/gitlab-ce"
    docker $DOCKERARGS rmi gitlab/gitlab-ce
  ;;
  "purge")
    echo "Purging gitlab $PROJECT-gitlab [$GITLABIP]"
    rm -R $SRV/gitlab
  ;;
  "check")
    echo "Checking gitlab "
    mkdir -p $SRV/errors/
    mkdir -p $SRV/checks/
    
    for check in check/*.sh
    do
     /bin/bash $check
    done
  ;;
esac
