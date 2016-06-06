#!/bin/bash

echo "Installing gitlab $PROJECT-gitlab [$GITLABIP]"

GITLABRB=$SRV/gitlab/etc/gitlab.rb

# Initialize gitlab directories and preparing config files

mkdir -p $SRV/gitlab/etc
mkdir -p $SRV/gitlab/log
mkdir -p $SRV/gitlab/opt

# Install and execute docker image

docker run -d \
  --name $PROJECT-gitlab \
  --net $PROJECT-net \
  --ip $GITLABIP \
  -v $SRV/gitlab/etc:/etc/gitlab \
  -v $SRV/gitlab/log:/var/log/gitlab \
  -v $SRV/gitlab/opt:/var/opt/gitlab \
  gitlab/gitlab-ce:latest

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

echo "Waiting 30 seconds for the Gitlab application to start..."
  
sleep 30