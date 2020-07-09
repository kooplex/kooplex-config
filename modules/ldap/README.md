## BUILD
```
bash kooplex.sh build ldap
```

* Creates module directories inside service persistent volumes, for
  * logging
  * configuration
  * data
* Populate initialization and addiser scripts
* Completes template files


## START
```
bash kooplex.sh start ldap
```

* Launches ldap in kubernetes master node

## INIT
```
bash kooplex.sh init ldap
```

* In running ldap pod runs the init script and creates root for user and group entries

----

## STOP
```
bash kooplex.sh stop ldap
```

* Deletes the ldap pod

## REMOVE
```
bash kooplex.sh remove ldap
```

* Deletes the ldap kubernetes service object

## PURGE
```
bash kooplex.sh purge ldap
```

* Deletes building directory
* Deletes module directories and their content:
  * logging
  * configuration
  * scripts
  * database content

