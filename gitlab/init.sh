#!/bin/bash

echo "Initializing gitlab $PROJECT-gitlab [$GITLABIP]"

echo "Creating Gitlab admin user..."

# Generate Gitlab random password
GITLABPASS=$(createsecret gitlab)

adduser gitlabadmin Gitlab Admin "admin@$DOMAIN" 10004 "$GITLABPASS"

# TODO: promote ldap user to admin
# TODO: disable standard login and self-registration via Gitlab