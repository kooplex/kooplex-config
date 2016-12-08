SYSMODULES="net base" # admin"
MODULES="ldap home gitlab notebook proxy nginx mysql " # hub dashboard"

OUTERHOST="http://wignercloud.compare-europe.hu"

PREFIX="kooplex"
DOCKERARGS=""
PROJECT="compare"
ROOT="/srv/"$PREFIX
DISKIMG="/var/diskimg"
DISKSIZE_GB="100"
LOOPNO="/dev/loop3"
USRQUOTA=10G
SUBNET="172.20.0.0/16"
DOMAIN="localhost"
DOMAIN="publicfacinghost.com"
SMTP=mail.elte.hu
EMAIL=dobos@complex.elte.hu
DUMMYPASS="almafa137"
