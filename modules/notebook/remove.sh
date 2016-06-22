#!/bin/bash

echo "Removing notebook $PROJECT-notebook [$NOTEBOOKIP]"

docker $DOCKERARGS stop $PROJECT-notebook

docker $DOCKERARGS rm $PROJECT-notebook

docker $DOCKERARGS rmi kooplex-notebook