#! /bin/bash

cd /local
./api.py > /tmp/api.log &

echo "API started: "
jobs
