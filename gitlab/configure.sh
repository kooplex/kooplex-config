#!/bin/bash

GITLABRB=$SRV/gitlab/etc/gitlab.rb

echo "Configuring gitlab $PROJECT-gitlab [$GITLABIP]"

# Generate Gitlab random password
GITLABPASS=$(createsecret gitlab)

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

echo "Creating Gitlab admin user..."

adduser gitlabadmin Gitlab Admin "admin@$DOMAIN" 10004 "$GITLABPASS"

# TODO: promote ldap user to admin
# TODO: disable standard login and self-registration via Gitlab