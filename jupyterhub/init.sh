#!/bin/bash

echo "Initializing jupyterhub $PROJECT-jupyterhub [$JUPYTERHUBIP]"

# Prepare configuration

cp jupyterhub_config.py $SRV/jupyterhub/