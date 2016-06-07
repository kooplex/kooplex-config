#!/bin/bash

nslcd -d &
jupyterhub --no-ssl jupyterhub_config.py