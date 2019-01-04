#!/bin/sh

service cron start

if [ $? == 0 ]; then
        echo "SUCCESS !"
else
        echo "Something went wrong!"

fi

