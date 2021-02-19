#!/bin/bash

# Change UID of NB_USER to NB_UID if it does not match 
if [ "$NB_UID" != $(id -u $NB_USER) ] ; then
    usermod -u $NB_UID $NB_USER
fi

