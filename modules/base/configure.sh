#!/bin/bash

DOCKER_HOST=$DOCKERARGS

case $VERB in
    "build")
      echo "Building base image ${PREFIX}-base" >&2
      cp build/Dockerfile-base $BUILDMOD_DIR
      sed -e s,##PREFIX##,$PREFIX, \
          build/Dockerfile-base-apt-packages-template > $BUILDMOD_DIR/Dockerfile-base-apt-packages
      sed -e s,##PREFIX##,$PREFIX, \
          build/Dockerfile-base-conda-template > $BUILDMOD_DIR/Dockerfile-base-conda
      cp scripts/entrypoint.sh $BUILDMOD_DIR
      cp scripts/bashrc_tail $BUILDMOD_DIR
      cp scripts/99-notebook $BUILDMOD_DIR
      cp scripts/start-notebook.sh $BUILDMOD_DIR
      cp scripts/jupyter-notebook-kooplex $BUILDMOD_DIR
      cp conf/kooplex-logo.png $BUILDMOD_DIR
      cp conf/jupyter_notebook_config.py $BUILDMOD_DIR
      cp conf/jupyter_report_config.py $BUILDMOD_DIR
      sed -e s,##REWRITEPROTO##,$REWRITEPROTO, \
          -e s/##FQDN##/$FQDN/ \
          scripts/preview-bokeh.sh-template > $BUILDMOD_DIR/preview-bokeh.sh
      sed -e s,##REWRITEPROTO##,$REWRITEPROTO, \
          -e s/##FQDN##/$FQDN/ \
          scripts/preview-nb-api.sh-template > $BUILDMOD_DIR/preview-nb-api.sh
      DN="dc=$(echo $FQDN | sed s/\\\./,dc=/g)"
      sed -e s,##PREFIX##,$PREFIX, \
          -e s/##LDAPORG##/$DN/ \
          -e s,##LDAP_ADMIN_PASSWORD##,"$LDAP_ADMIN_PASSWORD", \
          conf/nslcd.conf-template > $BUILDMOD_DIR/nslcd.conf
      docker $DOCKERARGS build -t ${PREFIX}-base -f $BUILDMOD_DIR/Dockerfile-base $BUILDMOD_DIR
      docker $DOCKERARGS build -t ${PREFIX}-base-apt-packages -f $BUILDMOD_DIR/Dockerfile-base-apt-packages $BUILDMOD_DIR
      docker $DOCKERARGS build -t ${PREFIX}-base-conda -f $BUILDMOD_DIR/Dockerfile-base-conda $BUILDMOD_DIR

      echo "Build notebook images" >&2
      for dt in build/Dockerfile-image-*-template ; do
          if [ -f $dt ] ; then
              d=$(basename $dt | sed s,-template,,)
              tag=$(echo $d | sed s,Dockerfile-,,)
              echo "Building $d for $tag" >&2
              sed -e s,##PREFIX##,${PREFIX}, \
                  $dt > $BUILDMOD_DIR/$d
              docker $DOCKERARGS build -t ${PREFIX}-${tag} -f $BUILDMOD_DIR/$d $BUILDMOD_DIR
              docker $DOCKERARGS tag ${PREFIX}-${tag} ${MY_REGISTRY}/${PREFIX}-${tag}
              docker $DOCKERARGS push ${MY_REGISTRY}/${PREFIX}-${tag}
          fi
      done


   # mkdir -p $SECRETS
   # mkdir -p $KEYS
   # mkdir -p $CONF_DIR
   # mkdir -p $LOG_DIR
   # cp $ORIGINAL_KEYS/*crt $ORIGINAL_KEYS/*key $KEYS/
   # 
   # docker $DOCKERARGS volume create -o type=none -o device=$KEYS -o o=bind ${PREFIX}-keys

   # cp  scripts/* $RF

   # ## CREATE BASE IMAGE
#  #  cp requirements.txt $RF
#  #  cp etc/conda-requirements*.txt $RF
   # cp Dockerfile $RF
   # sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-conda-extras-template > $RF/Dockerfile-base-conda-extras
   # sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-slurm-template > $RF/Dockerfile-base-slurm
   # sed -e "s/##PREFIX##/${PREFIX}/" Dockerfile-base-singularity-template > $RF/Dockerfile-base-singularity
 
   # docker $DOCKERARGS build -t ${PREFIX}-base-conda-extras -f $RF/Dockerfile-base-conda-extras  $RF 
   # docker $DOCKERARGS build -t ${PREFIX}-base-slurm -f $RF/Dockerfile-base-slurm  $RF 
   # docker $DOCKERARGS build -t ${PREFIX}-base-singularity -f $RF/Dockerfile-base-singularity  $RF 
   # echo "Generating secrets..."

  ;;
  "install")

  ;;
  "start")
    
  ;;
  "init")
    
  ;;
  "stop")
    
  ;;
  "remove")

  ;;

    "purge")
      echo "Removing docker images" >&2
      for i in ${PREFIX}-base-conda ${PREFIX}-base-apt-packages ${PREFIX}-base; do
          docker $DOCKERARGS rmi $i
          echo "Removed image $i" >&2
      done
      for dt in build/Dockerfile-image-*-template ; do
          if [ -f $dt ] ; then
              d=$(basename $dt | sed s,-template,,)
              tag=$(echo $d | sed s,Dockerfile-,,)
              docker $DOCKERARGS rmi ${PREFIX}-${tag} ${MY_REGISTRY}/${PREFIX}-${tag}
              echo "Removed ${PREFIX}-${tag} ${MY_REGISTRY}/${PREFIX}-${tag}" >&2
          fi
      done
    ;;

  "clean")
  ;;
esac
