#! /bin/bash

SEAFILE_DIR=/opt/seafile/seafile-client
mkdir -p $SEAFILE_DIR
seaf-cli init -d $SEAFILE_DIR 

seaf-cli start
 
echo "Seafile client is running in the background." >> $LOG

