SYSMODULES="net base" # admin"
MODULES="ldap home gitlab notebook proxy nginx mysql owncloud " # hub dashboard"

OUTERHOST="novo1.complex.elte.hu"

PREFIX="kooplex"
DOCKERIP="novo1.krft"
DOCKERPORT="2375"
DOCKERARGS="-H tcp://$DOCKERIP:$DOCKERPORT"
PROJECT="compare"
ROOT="/srv/kooplex/mnt_"$PREFIX
DISKIMG="/srv/kooplex/diskimg"
DISKSIZE_GB="100"
LOOPNO="/dev/loop0"
USRQUOTA=10G
SUBNET="172.20.0.0/16"
DOMAIN="novo1.complex.elte.hu"
SMTP=mail.elte.hu
EMAIL=dobos@complex.elte.hu
DUMMYPASS="almafa137"
