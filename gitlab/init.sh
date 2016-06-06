#!/bin/bash

echo "Initializing gitlab $PROJECT-gitlab [$GITLABIP]"

echo "Creating Gitlab admin user..."

# Generate Gitlab and keyfile random password
GITLABPASS=$(createsecret gitlab)
SSHKEYPASS=$(createsecret sshkey)

adduser gitlabadmin Gitlab Admin "admin@$DOMAIN" "$GITLABPASS" 10001
gitlab_makeadmin gitlabadmin

# TODO: promote ldap user to admin
# TODO: disable standard login and self-registration via Gitlab