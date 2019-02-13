#!/bin/bash

RF=$BUILDDIR/notebooks
    echo "Building image $PREFIX-notebooks $EXTRA"

case $VERB in
  "build")
    echo "Building image $PREFIX-notebooks $EXTRA"


     mkdir -p $RF
     
     for imagedir in ./image-*
#     for i in $EXTRA
     do
#        imagedir="./image-"$i
        mkdir -p $RF/$imagedir
        sed -e "s/##PREFIX##/${PREFIX}/" $imagedir/Dockerfile-template > $RF/$imagedir/Dockerfile
        sed -e "s/##PREFIX##/${PREFIX}/" scripts/start-notebook.sh-template > $RF/$imagedir/start-notebook.sh
	mkdir -p ${RF}/$imagedir/init
        cp scripts/{kooplex-logo.png,jupyter_notebook_config.py,??-*.sh,manage_mount.sh,jupyter-notebook-kooplex} ${RF}/$imagedir/
        cp scripts/??-*.sh ${RF}/$imagedir/init
        cp scripts/{entrypoint-rstudio.sh,bashrc_tail,rsession.conf,rserver.conf,rstudio-nginx.conf}  ${RF}/$imagedir/
        cp DockerFile-pieces/* ${RF}/$imagedir

#####
  printf "$(ldap_ldapconfig)\n\n" > ${RF}/$imagedir/ldap.conf
  printf "$(ldap_nsswitchconfig)\n\n" > ${RF}/$imagedir/nsswitch.conf
  printf "$(ldap_nslcdconfig)\n\n" > ${RF}/$imagedir/nslcd.conf
  chown root ${RF}/$imagedir/nslcd.conf
  chmod 0600 ${RF}/$imagedir/nslcd.conf

######NOTE: jupyter_report_config.py not in the image

        docfile=${imagedir}/Dockerfile
        imgname=${imagedir#*image-}



     	echo "Building image from $docfile"
        cat ${RF}/${imagedir}/9-Endpiece.docker >> ${RF}/$docfile
        docker $DOCKERARGS build -f ${RF}/$docfile -t ${PREFIX}-notebook-${imgname} ${RF}/$imagedir
       
     done

    
  ;;
  "install")
  ;;
    
  "start")
    # TODO: we have a single notebook server now, perhaps there will
    # one per user later or more if we scale out
    # echo "Starting notebook $PROJECT-notebook [$NOTEBOOKIP]"
    # docker $DOCKERARGS start $PROJECT-notebook
  ;;
  "init")
    
  ;;
  "stop")
    echo "Stopping notebook $PROJECT-notebook [$NOTEBOOKIP]"
#    docker $DOCKERARGS stop $PROJECT-notebook
  ;;
  "remove")
    echo "Removing notebook $PROJECT-notebook [$NOTEBOOKIP]"
#    docker $DOCKERARGS rm $PROJECT-notebook
  ;;
  "purge")
    echo "Purging notebook $PROJECT-notebook [$NOTEBOOKIP]"
    rm -R $SRV/notebook
  ;;
  "clean")
    echo "Cleaning base image $PREFIX-notebook"
#    docker $DOCKERARGS rmi $PREFIX-notebook
#FIXME: hard coded
    docker $DOCKERARGS images |grep kooplex-notebook| awk '{print $1}' | xargs -n  1 docker $DOCKERARGS rmi
  ;;
esac
