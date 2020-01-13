All commands should be run from repositories root folder ```$KOOPLEX_CONFIG_DIR```

## BUILD
```
bash kooplex.sh build hub
```

* Creates all basic directories and their volumes
* Pulls the kooplex-hub code (https://github.com/kooplex/kooplex-hub)
* Completes template files
* Builds docker images


## START
```
bash kooplex.sh start hub
```

* Launches hub and it's database, hub-mysql

## INIT
```
bash kooplex.sh init hub
```

* Creates database in the hub-mysql
* Creates admin for django. You need to enter a password there interactively
* Migrates django tables and models
