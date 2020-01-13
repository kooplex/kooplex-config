#!/bin/bash

replace_slash() {
	echo $1 | sed 's/\//\\\//g'
}

MODULE_NAME=notebook
RF=$BUILDDIR/${MODULE_NAME}

case $VERB in
  "build")
    echo "Building image $PREFIX-${MODULE_NAME} $EXTRA"


     mkdir -p $RF
     
#     for imagedir in ./image-*
     for i in $EXTRA
     do
        imagedir="./image-"$i
        mkdir -p $RF/$imagedir
	[ -e $imagedir/conda-requirements.txt ] &&  cp -p $imagedir/conda-requirements.txt $RF/$imagedir/conda-requirements.txt
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


	# copy necessary files from other module builds
	for nec_file in `ls $BUILDDIR/*/$NOTEBOOK_DOCKER_EXTRA/*`
	do
		cp $nec_file ${RF}/$imagedir/
	done

#####
  printf "$(ldap_ldapconfig)\n\n" > ${RF}/$imagedir/ldap.conf
  printf "$(ldap_nsswitchconfig)\n\n" > ${RF}/$imagedir/nsswitch.conf
  printf "$(ldap_nslcdconfig)\n\n" > ${RF}/$imagedir/nslcd.conf
  chown root ${RF}/$imagedir/nslcd.conf
  chmod 0600 ${RF}/$imagedir/nslcd.conf

######NOTE: jupyter_report_config.py not in the image

        docfile=${imagedir}/Dockerfile
        imgname=${imagedir#*image-}

        if [ ! ${IMAGES_FROM_REGISTRY} ]; then
		fdfd
             sed -e "s/##PREFIX##/${PREFIX}/" $imagedir/Dockerfile-template > $RF/$imagedir/Dockerfile
             docker $DOCKERARGS build -f ${RF}/$docfile -t ${PREFIX}-${MODULE_NAME}-${imgname}-base ${RF}/$imagedir
     else
	     echo "Using base image ${PREFIX}-${MODULE_NAME}-${imgname}-base form pulled source"
     fi

     	echo "Building image from $docfile"
	for docker_piece in `ls ${RF}/${imagedir}/*-Docker-piece`
	do
		sed -e "s/##BASE##/${PREFIX}-${MODULE_NAME}-${imgname}-base/" $docker_piece >> ${RF}/$docfile-final
	done

#        cat ${RF}/${imagedir}/9-Endpiece.docker >> ${RF}/$docfile
        docker $DOCKERARGS build -f ${RF}/$docfile-final -t ${PREFIX}-${MODULE_NAME}-${imgname} ${RF}/$imagedir
       
     done
  ;;
  "install")

# OUTER-NGINX
    sed -e "s/##PREFIX##/$PREFIX/" outer-nginx-${MODULE_NAME}-template > $CONF_DIR/outer_nginx/sites-enabled/${MODULE_NAME}
        docker $DOCKERARGS restart $PREFIX-outer-nginx
    
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
    echo "Stopping ${MODULE_NAME} $PROJECT-${MODULE_NAME} [$NOTEBOOKIP]"
#    docker $DOCKERARGS stop $PROJECT-notebook
  ;;
  "remove")
    echo "Removing ${MODULE_NAME} $PROJECT-${MODULE_NAME} [$NOTEBOOKIP]"
#    docker $DOCKERARGS rm $PROJECT-notebook
  ;;
  "purge")
    echo "Purging ${MODULE_NAME} $PROJECT-${MODULE_NAME} [$NOTEBOOKIP]"
    rm -R $SRV/${MODULE_NAME}
  ;;
  "clean")
    echo "Cleaning base image $PREFIX-${MODULE_NAME}"
#    docker $DOCKERARGS rmi $PREFIX-notebook
#FIXME: hard coded
#    docker $DOCKERARGS images |grep kooplex-notebook| awk '{print $1}' | xargs -n  1 docker $DOCKERARGS rmi
  ;;
esac
