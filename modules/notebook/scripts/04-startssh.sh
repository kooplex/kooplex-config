#! /bin/bash

if [ -z "$REPORT_TYPE" ] ; then
	service ssh start
	echo "ssh started"
else
	echo "ssh not started"
fi
