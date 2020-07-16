!!! Important
delete hydracode/consent/application/config/installed.txt 

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

## INSERT hydra secret and clientid into consent/application/config/hydra.php
<?php defined('BASEPATH') || exit('No direct script access allowed');

$config["hydra.consent_client"] = '##CLIENT_ID##';
$config["hydra.url"] = '##HYDRA_URL##';
$config["hydra.consent_secret"] = '##HYDRA_SECRET##';

