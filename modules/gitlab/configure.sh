#!/bin/bash

case $VERB in
  "install")
    echo "Installing gitlab $PROJECT-gitlab [$GITLABIP]"
    
    mkdir -p $SRV/gitlab/etc
    mkdir -p $SRV/gitlab/log
    mkdir -p $SRV/gitlab/opt
    chown -R root $SRV/gitlab
    chmod -R 755 $SRV/gitlab
    
    GITLABRB=$SRV/gitlab/etc/gitlab.rb
    echo "
external_url 'http://$DOMAIN/gitlab'

gitlab_rails['gitlab_email_from'] = '$EMAIL'
gitlab_rails['gitlab_email_display_name'] = '$PROJECT gitlab'
gitlab_rails['gitlab_email_reply_to'] = '$EMAIL'
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = '$SMTP'

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

" > $GITLABRB
    
    docker $DOCKERARGS create \
      --name $PROJECT-gitlab \
      --hostname $PROJECT-gitlab \
      --net $PROJECT-net \
      --ip $GITLABIP \
      -v $SRV/gitlab/etc:/etc/gitlab \
      -v $SRV/gitlab/log:/var/log/gitlab \
      -v $SRV/gitlab/opt:/var/opt/gitlab \
      -p 23:22 \
      gitlab/gitlab-ce
      
  ;;
  "start")
    echo "Starting gitlab $PROJECT-gitlab [$GITLABIP]"
    docker $DOCKERARGS start $PROJECT-gitlab
    echo "Waiting 30 seconds for the Gitlab application to start..."
    sleep 30
  ;;
  "init")
    echo "Initializing gitlab $PROJECT-gitlab [$GITLABIP]"
    echo "Creating Gitlab admin user..."
    
    # Generate Gitlab and keyfile random password
    GITLABPASS=$(createsecret gitlab)
    SSHKEYPASS=$(createsecret sshkey)

    adduser gitlabadmin Gitlab Admin "admin@$DOMAIN" "$GITLABPASS" 10001
    gitlab_makeadmin gitlabadmin

    # TODO: disable standard login and self-registration via Gitlab
  ;;
  "stop")
    echo "Stopping gitlab $PROJECT-gitlab [$GITLABIP]"
    docker $DOCKERARGS stop $PROJECT-gitlab
  ;;
  "remove")
    echo "Removing gitlab $PROJECT-gitlab [$GITLABIP]"
    docker $DOCKERARGS rm $PROJECT-gitlab
  ;;
  "purge")
    echo "Purging gitlab $PROJECT-gitlab [$GITLABIP]"
    rm -R $SRV/gitlab
  ;;
esac