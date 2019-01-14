#! /bin/bash

if [ $# -lt 4 ] ; then
    echo "$0 <user> <key> <host> <command>" >&2
    exit 1
fi

USER=$1
shift
KEY=$1
shift
REPOHOST=$1
shift
COMMAND=$@

#########################################################
if [ ! -f $KEY ] ; then
    echo "Cannot find the key $KEY" >&2
    exit 1
fi

if [ -z "$USER" -o "$USER" = "root" ] ; then
    echo "User must be set and not a root" >&2
    exit 1
fi

id $USER
if [ ! $? -eq 0 ] ; then
    echo "User $USER does not exist" >&2
    exit 1
fi

#FIXME: make sure user has the key!!!

#########################################################
AGENTSOCKET=/tmp/$USER
COMMAND1="ssh-agent -a $AGENTSOCKET"
COMMAND2="SSH_AUTH_SOCK=$AGENTSOCKET ssh-add $KEY"

function sudo_exec {
    echo sudo -i -u $USER sh -c "'$@'" | sh
}

function getpids {
    PIDS=$(ps -U $USER -o '%p;%a' | grep "$COMMAND1" | sed s,';.*',,)
    echo "Running agents: $PIDS"
}

function addkey {
    SSH_AUTH_SOCK=$AGENTSOCKET ssh-add -l | grep -q -E "$KEY\>"
    if [ $? -eq 0 ] ; then
         echo "Key already present"
    else
         sudo_exec $COMMAND2
         echo "Key added"
    fi
}

function addhostkey {
    F=/home/$USER/.ssh/know_hosts
    HK=$(sudo_exec ssh-keyscan -H $REPOHOST)
    if [ -f $F ] ; then
	grep -q $(echo $HK | awk '{ print $3 }') $F
	if [ $? -eq 0 ] ; then
	    echo "Host fingerprint present"
	else
	    echo $HK >> $F
	    echo "Host fingerprint added"
	fi
    else
        echo $HK >> $F
	echo "Host fingerprint added"
    fi
}

getpids

if [ -S $AGENTSOCKET ] ; then
    if [ -z "$PIDS" ] ; then
        rm $AGENTSOCKET
        sudo_exec $COMMAND1
        echo "Dangling socket removed, new agent started"
    else
        echo "No precess killed or started"
    fi
else
    if [ ! -z "$PIDS" ] ; then
        kill -9 $PIDS
        echo "Old agents ($PIDS) killed"
    fi
    sudo_exec $COMMAND1
    echo "New agent started"
fi

addkey
addhostkey

echo "Executing SSH_AUTH_SOCK=$AGENTSOCKET $COMMAND"
sudo_exec SSH_AUTH_SOCK=$AGENTSOCKET $COMMAND

