#! /bin/bash

if [ -z "$REPORT_TYPE" ] ; then
	if [ -z "$SSH_AUTH_SOCK" ] ; then
		export SSH_AUTH_SOCK=/tmp/$NB_USER
	fi
        exec su $NB_USER -c "ssh-agent -a $SSH_AUTH_SOCK"
	echo "ssh-agent started"
else
	echo "ssh-agent not started"
fi
