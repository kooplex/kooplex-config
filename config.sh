SYSMODULES="base net" # admin"
MODULES="ldap home gitlab notebook proxy nginx mysql " # hub dashboard"

# Prefix all directories
PREFIX="kooplex"
ROOT="/srv/$PREFIX"

# The project name will be used a prefix for all docker containers
PROJECT="compare"

# LDAP domain name
DOMAIN="localhost"

# Extenal URL of the nginx proxy
EXTERNALHOST="http://dobos.compare.vo.elte.hu"

# Outgoint email settings
SMTP=mail.elte.hu
EMAIL=dobos@complex.elte.hu

# Use an automatically generated password
# DUMMYPASS=
# Use a well-known password everywhere (for development and testing)
DUMMYPASS="almafa137"

# Docker settings
# Pass these arguments to the docker daemon
DOCKERARGS=""
SUBNET="172.20.0.0/16"

# LDAP settings
LDAPPORT=666

# Home volume use host file system
# HOME_DISKIMG=
# Home volume use image file with loopback
# This option allows quotas
HOME_DISKIMG="home.img"
HOME_DISKSIZEGB="2"
HOME_DISKLOOPNO="/dev/loop3"
HOME_USRQUOTA="120M"