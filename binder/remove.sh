#!/bin/bash

docker-compose -p kooplexbinder down 
docker rmi kooplexbinderhub
docker rmi kooplexbindersingleuser

