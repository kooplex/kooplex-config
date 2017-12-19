#! /bin/bash

PATCH=$(dirname $0)/patch-gitconfig.sh
USER=$1
AGENTSOCKET=/tmp/$USER
COMMAND="ssh-agent -a $AGENTSOCKET"
COMMAND2="SSH_AUTH_SOCK=$AGENTSOCKET ssh-add \$HOME/.ssh/gitlab.key"

function sudo_exec {
  echo sudo -i -u $USER sh -c "'$@'" | sh
}

function getpids {
  PIDS=$(ps -U $USER -o '%p;%a' | grep "$COMMAND" | sed s,';.*',,)
  echo "Running agents: $PIDS"
}

function addkey {
  SSH_AUTH_SOCK=$AGENTSOCKET ssh-add -l | grep -q .ssh/gitlab.key
  if [ $? -eq 0 ] ; then
     echo "Key already present"
  else
     sudo_exec $COMMAND2
     echo "Key added"
  fi
}

$PATCH $USER

getpids

if [ -S $AGENTSOCKET ] ; then
  if [ -z "$PIDS" ] ; then
      rm $AGENTSOCKET
      sudo_exec $COMMAND
      echo "Dangling socket removed, new agent started"
  else
      echo "No precess killed or started"
  fi
else
  if [ ! -z "$PIDS" ] ; then
      kill -9 $PIDS
      echo "Old agents ($PIDS) killed"
  fi
  sudo_exec $COMMAND
  echo "New agent started"
fi

addkey
