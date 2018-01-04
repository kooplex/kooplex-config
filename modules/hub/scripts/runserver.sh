#! /bin/bash


echo "STARTING FAKE"

sleep 3600

cd /kooplexhub/kooplexhub/
/usr/bin/python3 manage.py runserver 0.0.0.0:80
