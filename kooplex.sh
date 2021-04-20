#!/bin/bash

MYPWD=$PWD
CONFIGDIR=$(realpath $(dirname $0))

for SRC in $CONFIGDIR/config.sh $CONFIGDIR/lib.sh ; do
    if [ ! -f $SRC ] ; then
        echo "$SRC is missing" >&2
        exit 1
    fi
    . $SRC
done


echo "Prefix $PREFIX" >&2

VERB=$1
shift

if [ "$1" = "all" ] ; then
  SVCS="$SYSMODULES $MODULES"
elif [ "$1" = "sys" ] ; then
  SVCS="$SYSMODULES"
else
  SVCS="$@"
fi

echo "Command $VERB" >&2
echo "Modules $SVCS" >&2
 
case $VERB in
  "create_clusterrole")
    echo "Create cluster role" >&2
    kubectl apply -f $BUILDDIR/clusterrole.yaml
    sed -e s,##NFS_CLIENT_PROVISIONER##,nfs-client-provisioner-runner-$PREFIX, \
        core/clusterrole.yaml-template > $BUILDDIR/clusterrole.yaml
    kubectl apply -f $BUILDDIR/clusterrole.yaml
    DONE=1
    ;;

  "delete_clusterrole")
    echo "Delete cluster role" >&2
    kubectl delete clusterrole nfs-client-provisioner-runner-$PREFIX
    DONE=1
    ;;


  "create_service_pv")
    echo "Create persistent volumes for services" >&2
    _mkdir $BUILDDIR
    pv_yaml
    kubectl apply -f $CONF_YAML
    DONE=1
  ;;
  "start_helper")
    echo "Starting helper pod" >&2
    kubectl create namespace $NS_HELPER
    pvc_yaml $NS_HELPER
    kubectl apply -f $CONF_YAML
    start_helper
    DONE=1
  ;;
  "stop_helper")
    echo "Deleting helper namespace $NS_HELPER" >&2
    kubectl delete namespace $NS_HELPER
    DONE=1
  ;;
  "delete_service_pv")
    echo "Remove persistent volumes for services" >&2
    pv_yaml
    kubectl delete -f $CONF_YAML
    DONE=1
  ;;
  "buildimage"|"build"|"install"|"start"|"uninstall"|"init"|"stop"|"remove"|"purge")
    set -e
  ;;
  "restart")
    $0 stop $@
    $0 start $@
    DONE=1
  ;;
  *)
    echo "Unknown command $VERB" >&2
    DONE=1
  ;;
esac

if [ -z "$DONE" ] ; then

  echo "Issue $VERB for each module..." >&2

  for MODULE_NAME in $SVCS
  do
    mkdir_build
    cd $CONFIGDIR/modules/$MODULE_NAME
    . ./configure.sh
  done

fi

cd $MYPWD

echo "Finished with $VERB." >&2
