# Kooplex configuration scripts

To install a kooplex instance, follow steps below. Substitute $PROJECT with your project name and
$SRV with the kooplex root directory on your host machine.

## Installation

* clone this repository

	$ git clone https://github.com/kooplex/kooplex-config.git

* modify config.sh as necessary
* configure network by running the following command on the docker _host_:

	$ sudo bash kooplex.sh build all
    $ sudo bash kooplex.sh install all
    $ sudo bash kooplex.sh init all

## Proxy configuration

* add following lines to configuration file _default_ of nginx _host_ 
 
  (e.g. /etc/nginx/sites-available/default):

```
server {
    listen $DOMAIN:80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://$NGINXIP/;
    }
}

## Remove

    $ sudo bash kooplex.sh stop all
    $ sudo bash kooplex.sh remove all
    
## Purge configuration

To remove ALL data, config and docker images

    $ sudo bash kooplex.sh purge all