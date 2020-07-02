## BUILD
```
bash kooplex.sh build manual
```

* Creates module directory in service data volume
* Pulls the kooplex-manual code (https://github.com/kooplex/Manual) in it
* Completes template files
* Builds docker image
* Pushes into my_image registry

## START
```
bash kooplex.sh start manual
```

* Launches pod of gitbook based manual 

## INSTALL

```
bash kooplex.sh install manual
```

* Prepares sites-enabled configuration for nginx
* Restarts nginx pod

## STOP

```
bash kooplex.sh stop manual
```

* Deletes the pod of the manual

## DELETE

```
bash kooplex.sh delete manual
```

* Deletes the service related to the manual
* _NOTE:_ sites-enabled configuration not removed

## PURGE

```
bash kooplex.sh purge manual
```

* Deletes building directory
* Deletes module's data folder
