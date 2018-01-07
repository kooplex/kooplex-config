#! /bin/bash

cd /kooplexhub/kooplexhub/
git pull
/usr/bin/python3 manage.py makemigrations hub
/usr/bin/python3 manage.py makemigrations 
/usr/bin/python3 manage.py migrate

