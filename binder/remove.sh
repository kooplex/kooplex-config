#!/bin/bash

docker-compose -p koplexbinder down 
docker rmi kooplexbinderhub
docker rmi kooplexbindersingleuser

