#!/bin/bash


rm -f jupyterhub.crt jupyterhub.csr jupyterhub.key jupyterhub.key.orig

openssl genrsa -passout pass:LopaszakoboN -des3 -out jupyterhub.key 1024
openssl req -passin pass:LopaszakoboN -new -key jupyterhub.key -out jupyterhub.csr \
-subj /C=GB/ST=Lancashire/L=Galgate/O=NewInn/OU=drinkingbrigade/CN=drunkard.co.uk
cp jupyterhub.key jupyterhub.key.orig
openssl rsa -passin pass:LopaszakoboN  -in jupyterhub.key.orig -out jupyterhub.key
openssl x509 -req -days 365 -in jupyterhub.csr -signkey jupyterhub.key -out jupyterhub.crt
 

