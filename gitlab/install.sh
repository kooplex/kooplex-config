#!/bin/bash

IP=$1

echo "Installing gitlab $PROJECT-gitlab [$IP]"

# Initialize gitlab directories and preparing config files

mkdir -p $SRV/gitlab/etc
mkdir -p $SRV/gitlab/log
mkdir -p $SRV/gitlab/opt

# Install and execute docker image

docker run -d \
  --name $PROJECT-gitlab \
  --net $PROJECT-net \
  --ip $IP \
  -v $SRV/gitlab/etc:/etc/gitlab \
  -v $SRV/gitlab/log:/var/log/gitlab \
  -v $SRV/gitlab/opt:/var/opt/gitlab \
  gitlab/gitlab-ce:latest

sleep 5

GITLABRB=$SRV/gitlab/etc/gitlab.rb

echo "external_url 'http://$DOMAIN/gitlab'" >> $GITLABRB
echo "gitlab_rails['gitlab_email_from'] = '$EMAIL'" >> $GITLABRB
echo "gitlab_rails['gitlab_email_display_name'] = '$PROJECT gitlab'" >> $GITLABRB
echo "gitlab_rails['gitlab_email_reply_to'] = '$EMAIL'" >> $GITLABRB
echo "gitlab_rails['smtp_enable'] = true" >> $GITLABRB
echo "gitlab_rails['smtp_address'] = ''$SMTP" >> $GITLABRB
