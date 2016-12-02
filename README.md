# Kooplex configuration scripts

To install a kooplex instance, follow steps below. Substitute $PROJECT with your project name and
$SRV with the kooplex root directory on your host machine.

## Installation

* clone this repository

    $ git clone https://github.com/kooplex/kooplex-config.git

* modify config.sh as necessary
* configure network by running the following command on the docker _host_:

    $ sudo bash kooplex.sh build
    $ sudo bash kooplex.sh install
    $ sudo bash kooplex.sh start
    $ sudo bash kooplex.sh init
    
Individual modules can be installed, started etc. by specifying the module name, e.g.

    $ sudo bash kooplex.sh start proxy
    
starts the proxy only. Multiple modules names can be listed.

Manual install steps

* build (creates images)
* install
* start
* init

Recommended :)  Install sequence is the following:

* sudo bash kooplex.sh build 
* sudo bash kooplex.sh install
* sudo bash kooplex.sh start
* sudo bash kooplex.sh init
* sudo bash kooplex.sh build hub
* sudo bash kooplex.sh install hub (after that only use "refresh hub"
* sudo bash kooplex.sh start hub
* sudo bash kooplex.sh init hub


## Proxy configuration

* add following lines to configuration file _default_ of nginx _host_ 
 
  (e.g. /etc/nginx/sites-available/default):

```
map $http_upgrade $connection_upgrade {
	default upgrade;
	'' close;
}

server {
    listen $DOMAIN:80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://$NGINXIP/;
    }
    
    location ~* /(api/kernels/[^/]+/(channels|iopub|shell|stdin)|terminals/websocket)/? {
        proxy_pass http://$NGINXIP;
        proxy_set_header      Host $host;
        # websocket support
        proxy_http_version    1.1;
        proxy_set_header      Upgrade $http_upgrade;
        proxy_set_header      Connection $connection_upgrade;
    }
    
    #In chrome the kernel stays busy, but if...
    location ~* /(api/sessions)/? {
        proxy_pass http://$NGINXIP;
        proxy_set_header      Host $host;
        # websocket support
        proxy_http_version    1.1;
        proxy_set_header      Upgrade $http_upgrade;
        proxy_set_header      Connection $connection_upgrade;
    }

}
```

## IMPORTANT NOTES
* Check whether all the necessary ports are open (ufw allow etc) e.g. docker port, http port

## Remove

    $ sudo bash kooplex.sh stop all
    $ sudo bash kooplex.sh remove all
    
Manual remove steps:

* remove
* purge
* clean (deletes images)
    
## Purge configuration

To remove ALL data and config

    $ sudo bash kooplex.sh purge all
    
To delete generated docker images

    $ sudo bash kooplex.sh clean all
