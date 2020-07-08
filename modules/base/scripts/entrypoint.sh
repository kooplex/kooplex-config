#!/bin/sh

for SCRIPT in /init/*
do
    if [ -x $SCRIPT ] ; then
        echo "Running init script: $SCRIPT"
	$SCRIPT
    elif [ -f $SCRIPT ] ; then
        echo "Sourcing init script: $SCRIPT"
        . $SCRIPT
    else
        echo "Not a file $SCRIPT"
    fi
done

echo "Sleeping for infinity"
exec sleep infinity
