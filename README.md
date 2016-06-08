# Kooplex configuration scripts

To install a kooplex instance, follow steps below. Substitute $PROJECT with your project name and
$SRV with the kooplex root directory on your host machine.

## Installation

* clone this repository

	git clone https://github.com/kooplex/kooplex-config.git

* modify config.sh as necessary
* configure network by runnin the following command on the docker _host_:

	./install.sh net admin

* ssh to admin machine or execute bash inside docker

	docker exec -ti $PROJECT-admin bash

* inside the admin container, execute

	cd $SRV/src/kooplex-config
	./install.sh

## Proxy configuration

nginx host setup will come here

## Remove

* inside the admin container, execute

	cd $SRV/src/kooplex-config
	./remove.sh

* on the host, execute

	./remove.sh net admin