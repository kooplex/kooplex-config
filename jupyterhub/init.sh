#!/bin/bash

echo "Initializing jupyterhub $PROJECT-jupyterhub [$JUPYTERHUBIP]"

# Prepare configuration

res="$(gitlab_addoauthclient "JupyterHub" "http://$DOMAIN/hub/oauth_callback")"
read -r uid secret <<< "$res"

echo $uid
echo $secret

echo "
c.JupyterHub.authenticator_class = 'oauthenticator.GitlabOAuthenticator'
c.GitlabOAuthenticator.oauth_callback_url = 'http://$DOMAIN/hub/oauth_callback'
c.GitlabOAuthenticator.client_id = '$uid'
c.GitlabOAuthenticator.client_secret = '$secret'

c.PAMAuthenticator.open_sessions = True
c.PAMAuthenticator.service = 'login'
" > $SRV/jupyterhub/