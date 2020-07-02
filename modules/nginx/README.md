## BUILD
```
bash kooplex.sh build nginx
```

* Creates module directories inside service persistent volumes, for
  * logging
  * configuration
  * data
* Populate configuration information, key files and html files
* Completes template files


## START
```
bash kooplex.sh start nginx
```

* Launches nginx in kubernetes master node

## STOP
```
bash kooplex.sh stop nginx
```

* Deletes the nginx pod

## REMOVE
```
bash kooplex.sh remove nginx
```

* Deletes the nginx kubernetes service object

## PURGE
```
bash kooplex.sh purge nginx
```

* Deletes building directory
* Deletes module directories and their content:
  * logging
  * configuration and keys
  * data
