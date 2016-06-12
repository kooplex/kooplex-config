# Kooplex configuration scripts

To install a kooplex instance, follow steps below. Substitute $PROJECT with your project name and
$SRV with the kooplex root directory on your host machine.

## Installation

* clone this repository

	git clone https://github.com/kooplex/kooplex-config.git

* modify config.sh as necessary
* configure network by running the following command on the docker _host_:

	./install.sh net admin

* ssh to admin machine or execute bash inside docker

	docker exec -ti $PROJECT-admin bash

* inside the admin container, execute

	cd $SRV/src/kooplex-config
	./install.sh
	
* and execute

    ./init.sh
    
    ./init.sh admin
	
    (it is important to stick to the proper order)

## Proxy configuration

* add following lines to configuration file _default_ of nginx _host_ 
 
  (e.g. /etc/nginx/sites-available/default):

>    server {
>    
>      listen $DOMAIN:80;
>      
>      server_name $DOMAIN;
>      
>      location / {
>      
>        proxy_pass http://$NGINXIP/;
>        
>      }
>      
>    }

## Remove

* inside the admin container, execute

	cd $SRV/src/kooplex-config
	./remove.sh

* on the host, execute

	./remove.sh net admin
