All commands should be run from repositories root folder ```$KOOPLEX_CONFIG_DIR```

## BUILD
```
bash kooplex.sh build hydra
```

* Creates directories and volumes for hydra and consent and their databases
* Pulls the consent code (https://github.com/kooplex/hydra-consent)
* Completes template files
* Builds docker images


## START
```
bash kooplex.sh start hydra
```

* Launches hydra, consent and their databases

## INIT
```
bash kooplex.sh init hydra
```

* Creates database in the hydra-mysql
* Creates admin for django. You need to enter a password there interactively
* Migrates django tables and models
