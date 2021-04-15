#!/bin/bash

case $VERB in
  "build")
      echo "Building image $PREFIX-${MODULE_NAME}" >&2
      IMAGE_NAME="$PREFIX-ei-$(basename ${MODULE_NAME})"
      cp build/start-notebook.sh ${BUILDMOD_DIR}/
      cp build/jupyter-notebook-kooplex ${BUILDMOD_DIR}/
      cp etc/{jupyter_notebook_config.py,jupyter_report_config.py,kooplex-logo.png,package-list-conda-bio.yml} ${BUILDMOD_DIR}/
      sed -e s,##BASE##,${PREFIX}-base, \
              build/Dockerfile-template \
              > ${BUILDMOD_DIR}/Dockerfile
      _mkdir $BUILDMOD_DIR/init
      cp scripts/{0?-*.sh,9?-*.sh} ${BUILDMOD_DIR}/init
      
      docker $DOCKERARGS build -t ${IMAGE_NAME} -f $BUILDMOD_DIR/Dockerfile $BUILDMOD_DIR
      docker $DOCKERARGS tag ${IMAGE_NAME} ${MY_REGISTRY}/${IMAGE_NAME}
      docker $DOCKERARGS push ${MY_REGISTRY}/${IMAGE_NAME}
  ;;

  "install")
      echo "Register in nginx ${PREFIX}-${MODULE_NAME}" >&2
      register_module_in_nginx
      IMAGE_NAME="$PREFIX-ei-$(basename ${MODULE_NAME})"
      echo "Register in hub ${IMAGE_NAME}" >&2
      kubectl exec -it ${PREFIX}-hub -- python3 /kooplexhub/kooplexhub/manage.py manage_image --add ${IMAGE_NAME}
  ;;

  "uninstall")
      deregister_module_in_nginx
      kubectl exec -it ${PREFIX}-hub -- python3 /kooplexhub/kooplexhub/manage.py manage_image --remove ${IMAGE_NAME}
  ;;

  "remove")
      echo "Removing $BUILDMOD_DIR" >&2
      rm -R -f $BUILDMOD_DIR
  ;;
esac
