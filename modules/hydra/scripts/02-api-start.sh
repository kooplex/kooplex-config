#! /bin/bash

cd /local && python3 api.py > /var/log/nginx/api.log &
