#! /bin/bash

env

httpd-foreground &
counter=1
while [ 1 -lt 2 ]; do
	for script in /opt/scripts/*py
	do
		python3 $script $counter
		echo $script, $counter
	done
	sleep 5
	counter=$((counter+1))
done

