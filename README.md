# Prerequisities

## Storage

Setup and configure an Local storage or an NFS server for persistent storage.

At server side create the necessary folders and grant write access for kooplex services

For example NFS service with a ZFS backend, you can create a volume and publish it to your kubernetes cluster nodes:

```bash
zfs create pool/k8plex  
zfs set mountpoint=/srv/vols/k8plex pool/k8plex
zfs set quota=10G pool/k8plex
zfs set sharenfs="rw=@FQDN_NODE1,insecure,no_root_squash,rw=@FQDN_NODE2,insecure,no_root_squash,..." pool/k8plex
zfs set acltype=posixacl pool/k8plex
```
One can configure k8plex services with separate volumes for different storage purposes, like one volume for service data, configuration and logs, and some other volumes for user data. For testing purposes a single volume setup recommended.

Service data, configuration and log folders are provisioned dynamically by NFS client provisioners. Folders for user data are mapped to several stand alone PVs. For those latter PVs the necessary subfolders need to be created in advance, otherwise a POD may fail to start during the mount phase, because the nfs server should raise a no such file or directory folder.

Following our example with the single exported volume case, do the following:

```bash
mkdir -p /srv/vols/k8plex/users
mkdir -p /srv/vols/k8plex/garbage
mkdir -p /srv/vols/k8plex/data/report
mkdir -p /srv/vols/k8plex/data/project
mkdir -p /srv/vols/k8plex/cache/_fs
mkdir -p /srv/vols/k8plex/cache/_git
mkdir -p /srv/vols/k8plex/cache/report_prepare
```

@veo2
root@node1:~# mkdir -p /srv/vols/k8plex
root@node1:~# mount nfsnode.int:/srv/vols/k8plex /srv/vols/k8plex



## Certificate

```bash
DIR=/srv/build/k8plex/cert
mkdir $DIR

HOST=k8plex
KEY_FILE=${DIR}/selfsigned-${HOST}.key
CERT_FILE=${DIR}/selfsigned-${HOST}.crt
HOST=${HOSTNAME}
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/C=HU/ST=BP/L=Budapest/O=EXAMPLE/CN=${HOSTNAME}"
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

## Hub

```bash
kooplex.sh build hub
kooplex.sh install hub
kooplex.sh start hub
kooplex.sh init hub
```

# Uninstallation steps

```bash
kooplex.sh uninstall hub 
kooplex.sh uninstall proxy 
kooplex.sh uninstall ldap 
kooplex.sh uninstall registry
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
FQDN="example.org"

PREFIX="aprefix"

#Access to docker 
DOCKERIP="/var/run/docker.sock"
DOCKERPORT=""
DOCKERPROTOCOL="unix"

#Where all the homes, config files etc will be
ROOT="/srv/"$PREFIX

#and scripts needed for building images etc.
BUILDDIR=$ROOT"/build"

#Domain in ldap
LDAPDOMAIN=$FQDN

SMTP="smtp"
SMTPPORT=25
EMAIL=

#Password for many things
DUMMYPASS=""

#Prints out debug information on "docker logs $PROJECT-hub"
HUB_DEBUG=True

ERROR_LOG="error.log"
CHECK_LOG="check.log"	

#Executables
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
