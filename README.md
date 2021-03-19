# Prerequisities

An NFS server for persistent storage.

At server side create the necessary folders and grant write access for kooplex services

Example NFS service with a ZFS backend
```bash
zfs create pool/k8plex
zfs set mountpoint=/srv/vols/k8plex pool/k8plex
zfs set quota=10G pool/k8plex
zfs set sharenfs="rw=@FQDN_NODE1,insecure,no_root_squash,rw=@FQDN_NODE2,insecure,no_root_squash,..." pool/k8plex
zfs set acltype=posixacl pool/k8plex

mkdir -p /srv/vols/k8plex/services/log
mkdir -p /srv/vols/k8plex/services/conf
mkdir -p /srv/vols/k8plex/services/data
```

# Installation steps

## Retrieve sources and configure k8plex

* clone this repository
* create configuration file

```bash
$ git clone -b kubernetes-ns https://github.com/kooplex/kooplex-config.git
$ cp kooplex-config/config.sh_template kooplex-config/config.sh
```

* edit configuration file

TBD

## Create a cluster role for nfs provisioning

```bash
kooplex.sh create_clusterrole
```

## Image registry

```bash
kooplex.sh build registry
kooplex.sh install registry
kooplex.sh start registry
```

## Proxy

```bash
kooplex.sh build proxy
kooplex.sh install proxy 
kooplex.sh start proxy 
```

## Ldap


```bash
kooplex.sh build ldap
kooplex.sh install ldap
kooplex.sh start ldap
kooplex.sh init ldap
```

# Uninstallation steps

```bash
kooplex.sh uninstall registry
kooplex.sh uninstall ldap 
kooplex.sh uninstall proxy 
kooplex.sh delete_clusterrole
kooplex.sh remove
```

Remove or back up NFS folders.


# Further reading

Visit the [Kooplex page](https://kooplex.github.io/) for more information.


BELOW LINE NEEDS REVISION


----



## Kooplex configuration scripts

To install a kooplex instance, follow steps below. Substitute $PROJECT with your project name and
$SRV with the kooplex root directory on your host machine.

## Installation

```bash
#The url that will be accessible from a browser
OUTERHOSTNAME="example.org"
OUTERHOSTPORT="89"

#The host name of a gateway or virtual host if there is any. If not use outerhost
#INNERHOST=$OUTERHOSTNAME
INNERHOST="192.168.1.15"
#If you can communicate through only one port on the outerhost then you have
#to create an extra nginx (e.g. in a container, because you will need to
#have access to certain ports in your inner network

PREFIX="aprefix"
PROJECT="projectname"

#Access to docker 
DOCKERIP="/var/run/docker.sock"
DOCKERPORT=""
DOCKERPROTOCOL="unix"

#Where all the homes, config files etc will be
ROOT="/srv/"$PREFIX

#and scripts needed for building images etc.
BUILDDIR=$ROOT"/build"

#Probably not needed
DISKIMG="/home/jegesm/Data/diskimg"
DISKSIZE_GB="20"
LOOPNO="/dev/loop3"
USRQUOTA=10G

#This is the subnet where the containers for services will be
SUBNET="172.20.0.0/16"

#Domain in ldap
LDAPDOMAIN=$OUTERHOSTNAME

SMTP="smtp"
SMTPPORT=25
EMAIL=

#Password for many things
DUMMYPASS=""

#This is the web protocol: http or https
REWRITEPROTO=http

#Prints out debug information on "docker logs $PROJECT-hub"
HUB_DEBUG=True

ERROR_LOG="error.log"
CHECK_LOG="check.log"	

#Executables
DOCKER_COMPOSE="docker-compose"
```
* For many of the following steps here you will need write access to the $ROOT and $BUILDDIR folders
* Individual modules can be installed, started etc. by specifying the module name, e.g.

    $ sudo bash kooplex.sh start proxy
    
starts the proxy only. Multiple module names can be listed or if left empty then will iterate on $SYSMODULES and $MODULES.

Manual install steps

* build (creates images and config files)
* install (creates containers out of images and runs maybe a script)
* start (starts containers)
* init (runs scripts in the containers, initializes 

Recommended :)  Install sequence is the following:

* sudo bash kooplex.sh build 
* sudo bash kooplex.sh install
* sudo bash kooplex.sh start
* sudo bash kooplex.sh init
* sudo bash kooplex.sh build hub
* sudo bash kooplex.sh install hub (after that use only "refresh hub")
* sudo bash kooplex.sh start hub
* sudo bash kooplex.sh init hub


## Proxy configuration of the $OUTERHOST or $INNERHOST if there are two layers

* add following lines to configuration file _default_ of nginx _host_ 
 
  (e.g. /etc/nginx/sites-available/default):

```
map $http_upgrade $connection_upgrade {
	default upgrade;
	'' close;
}

server {
    listen $INNERHOST:80;
    server_name $INNERHOSTNAME;
    location / {
    	proxy_set_header      Host $http_host;
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

## Remove containers

    $ bash kooplex.sh stop all
    $ bash kooplex.sh remove all
    
Manual remove steps:

* remove (containers)
* purge (configuration files, datatabases and directories)
* clean (deletes images)
    
## Purge configuration files, datatabases and directories

To remove ALL data and config

    $ bash kooplex.sh purge all
    
To delete generated docker images

    $ bash kooplex.sh clean all
