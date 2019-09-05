#!/bin/bash

replace_slash() {
	echo $1 | sed 's/\//\\\//g'
}


RF=$BUILDDIR/notebooks
    echo "Building image $PREFIX-notebooks $EXTRA"

case $VERB in
  "build")
    echo "Building image $PREFIX-notebooks $EXTRA"


     mkdir -p $RF
     
#     for imagedir in ./image-*
     for i in $EXTRA
     do
        imagedir="./image-"$i
        mkdir -p $RF/$imagedir
	[ -e $imagedir/conda-requirements.txt] &&  cp -p $imagedir/conda-requirements.txt $RF/$imagedir/conda-requirements.txt
        sed -e "s/##PREFIX##/${PREFIX}/" $imagedir/Dockerfile-template > $RF/$imagedir/Dockerfile
        sed -e "s/##PREFIX##/${PREFIX}/" scripts/start-notebook.sh-template > $RF/$imagedir/start-notebook.sh
        sed -e "s/##OUTERHOSTNAME##/${OUTERHOSTNAME}/"\
	    -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" scripts/rstudio-login.html-template > $RF/$imagedir/rstudio-login.html
        sed -e "s/##OUTERHOST##/${OUTERHOST}/"\
	    -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" scripts/preview-bokeh.sh-template > $RF/$imagedir/preview-bokeh.sh
        sed -e "s/##OUTERHOST##/${OUTERHOST}/"\
	    -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" scripts/preview-nb-api.sh-template > $RF/$imagedir/preview-nb-api.sh

	mkdir -p ${RF}/$imagedir/init
	echo $(replace_slash $FUNCTIONAL_VOLUME_MOUNT_POINT)
	sed -e "s/##FUNCTIONAL_VOLUME_MOUNT_POINT##/$(replace_slash $FUNCTIONAL_VOLUME_MOUNT_POINT)/" scripts/11_init_bashrcs-template > $RF/$imagedir/init/11_init_bashrcs
        sed -e "s/##FUNCTIONAL_VOLUME_MOUNT_POINT##/$(replace_slash $FUNCTIONAL_VOLUME_MOUNT_POINT)/" scripts/12_conda_envs-template > $RF/$imagedir/init/12_conda_envs
        cp scripts/{kooplex-logo.png,jupyter_notebook_config.py,jupyter_report_config.py,manage_mount.sh,jupyter-notebook-kooplex} ${RF}/$imagedir/
	cp scripts/{0?-*.sh,9?-*.sh} ${RF}/$imagedir/init
        cp scripts/{entrypoint-rstudio.sh,rstudio-user-settings,rstudio-nginx.conf}  ${RF}/$imagedir/
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
