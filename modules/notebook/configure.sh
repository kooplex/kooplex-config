#!/bin/bash


MODULE_NAME=notebook
RF=$BUILDDIR/${MODULE_NAME}

case $VERB in
  "build")
    echo "Building image $PREFIX-${MODULE_NAME} $EXTRA"


     mkdir -p $RF
     
#     for imagedir in ./image-*
     for IMAGE_TYPE in $EXTRA
     do
        IMAGE_DIR="./image-"$IMAGE_TYPE
        BUILD_IMAGE_DIR=${RF}/${IMAGE_DIR}
        mkdir -p ${BUILD_IMAGE_DIR} 
        IMAGE_NAME=${PREFIX}-${MODULE_NAME}-${IMAGE_TYPE}

	[ -e ${IMAGE_DIR}/conda-requirements.txt ] &&  cp -p ${IMAGE_DIR}/conda-requirements.txt ${BUILD_IMAGE_DIR}/conda-requirements.txt
        sed -e "s/##PREFIX##/${PREFIX}/" scripts/start-notebook.sh-template > ${BUILD_IMAGE_DIR}/start-notebook.sh
        sed -e "s/##OUTERHOSTNAME##/${OUTERHOSTNAME}/"\
	    -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" scripts/rstudio-login.html-template > ${BUILD_IMAGE_DIR}/rstudio-login.html
        sed -e "s/##OUTERHOST##/${OUTERHOST}/"\
	    -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" scripts/preview-bokeh.sh-template > ${BUILD_IMAGE_DIR}preview-bokeh.sh
        sed -e "s/##OUTERHOST##/${OUTERHOST}/"\
	    -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" scripts/report-dash.sh-template > ${BUILD_IMAGE_DIR}/report-dash.sh
        sed -e "s/##OUTERHOST##/${OUTERHOST}/"\
	    -e "s/##REWRITEPROTO##/${REWRITEPROTO}/" scripts/preview-nb-api.sh-template > ${BUILD_IMAGE_DIR}/preview-nb-api.sh

	mkdir -p ${BUILD_IMAGE_DIR}/init
	sed -e "s,##FUNCTIONAL_VOLUME_MOUNT_POINT##,$FUNCTIONAL_VOLUME_MOUNT_POINT," scripts/11_init_bashrcs-template > ${BUILD_IMAGE_DIR}/init/11_init_bashrcs
        sed -e "s,##FUNCTIONAL_VOLUME_MOUNT_POINT##,$FUNCTIONAL_VOLUME_MOUNT_POINT," scripts/12_conda_envs-template > ${BUILD_IMAGE_DIR}/init/12_conda_envs
        cp scripts/{kooplex-logo.png,jupyter_notebook_config.py,jupyter_report_config.py,manage_mount.sh,jupyter-notebook-kooplex} ${BUILD_IMAGE_DIR}/
	cp scripts/{0?-*.sh,9?-*.sh} ${BUILD_IMAGE_DIR}/init
        cp scripts/{entrypoint-rstudio.sh,rstudio-user-settings,rstudio-nginx.conf}  ${BUILD_IMAGE_DIR}/
        cp DockerFile-pieces/* ${BUILD_IMAGE_DIR}/


	# copy necessary files from other module builds
        if [ -d $BUILDDIR/*/$NOTEBOOK_DOCKER_EXTRA/* ]; then
    	   for nec_file in `ls $BUILDDIR/*/$NOTEBOOK_DOCKER_EXTRA/*`
    	   do
    	   	cp $nec_file ${BUILD_IMAGE_DIR}/
    	   done
        fi
#####
  printf "$(ldap_ldapconfig)\n\n" > ${BUILD_IMAGE_DIR}/ldap.conf
  printf "$(ldap_nsswitchconfig)\n\n" > ${BUILD_IMAGE_DIR}/nsswitch.conf
  printf "$(ldap_nslcdconfig)\n\n" > ${BUILD_IMAGE_DIR}/nslcd.conf
  chown root ${BUILD_IMAGE_DIR}/nslcd.conf
  chmod 0600 ${BUILD_IMAGE_DIR}/nslcd.conf

######NOTE: jupyter_report_config.py not in the image

        DOCKER_FILE=${BUILD_IMAGE_DIR}/Dockerfile

        if [ ${PULL_IMAGE_FROM_REPOSITORY} ]; then
             BASE_IMAGE_NAME=${IMAGE_REPOSITORY_URL}${IMAGE_REPOSITORY_PREFIX}-notebook-${IMAGE_TYPE}-base
	     echo "Using base image ${BASE_IMAGE_NAME} (pulled from repository}"
             docker $DOCKERARGS pull ${BASE_IMAGE_NAME}
	     echo "Image PULLED from repository"
#             docker tag ${IMAGE_NAME}-base ${PREFIX}-${MODULE_NAME}-$imgname-base
#	     echo "Image TAGGED from repository"
        else
             BASE_IMAGE_NAME=${PREFIX}-notebook-base
             sed -e "s/##PREFIX##/${PREFIX}/" \
                 -e "s,##IMAGE_NAME##,${BASE_IMAGE_NAME},"  ${IMAGE_DIR}/Dockerfile-template > ${DOCKER_FILE}
             docker $DOCKERARGS build -f ${DOCKER_FILE} -t ${IMAGE_NAME} ${BUILD_IMAGE_DIR}
#             docker tag  ${PREFIX}-${MODULE_NAME}-$imgname-base "localhost:5000/"${MODULE_NAME}-$imgname-base
#             docker push "localhost:5000/"${MODULE_NAME}-$imgname-base
        fi

        echo "FROM ${BASE_IMAGE_NAME}" > ${DOCKER_FILE}-final

     	echo "Building image from $DOCKER_FILE"
	for docker_piece in `ls ${BUILD_IMAGE_DIR}/*-Docker-piece`
	do
		cat $docker_piece >> ${DOCKER_FILE}-final
	done

#        cat ${RF}/${imagedir}/9-Endpiece.docker >> ${RF}/$docfile
        docker $DOCKERARGS build --no-cache -f ${DOCKER_FILE}-final -t ${PREFIX}-${MODULE_NAME}-${IMAGE_TYPE} ${BUILD_IMAGE_DIR}

       
     done
  ;;
    
  "install-hydra")
  #  register_hydra $MODULE_NAME
  ;;
  "uninstall-hydra")
   # unregister_hydra $MODULE_NAME
  ;;
  "install-nginx")
    register_nginx $MODULE_NAME
  ;;
  "uninstall-nginx")
    unregister_nginx $MODULE_NAME
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
    rm -r $RF
#    docker $DOCKERARGS rmi $PREFIX-notebook
#FIXME: hard coded
#    docker $DOCKERARGS images |grep kooplex-notebook| awk '{print $1}' | xargs -n  1 docker $DOCKERARGS rmi
  ;;
esac
