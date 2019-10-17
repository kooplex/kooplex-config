#! /bin/bash

if [ -z "$REPORT_TYPE" ] ; then
        exec su $NB_USER -c "ssh-agent -a /tmp/$NB_USER ; export SSH_AUTH_SOCK=/tmp/$NB_USER"
	echo "ssh-agent started"
else
	echo "ssh-agent not started"
fi
