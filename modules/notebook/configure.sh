#!/bin/bash

RF=$BUILDDIR/notebooks


case $VERB in
  "build")
    echo "Building image $PREFIX-notebooks"

#    docker $DOCKERARGS build -t $PREFIX-notebook .
    
     mkdir -p $RF
     for imagedir in ./image-*
     do
        cp -r image-* $RF
        cp scripts/start-notebook.sh scripts/start-report.sh  scripts/jupyter-notebook-kooplex scripts/jupyter-report-kooplex  ${RF}/$imagedir
        docfile=${imagedir}/Dockerfile
        imgname=${imagedir#*image-}
     	echo "Building image from $docfile"
        docker $DOCKERARGS build -f ${RF}/$docfile -t ${PREFIX}-notebook-${imgname} ${RF}/$imagedir
       
     done

    
  ;;
  "install")
    echo "Installing notebook $PROJECT-notebook [$NOTEBOOKIP]"

    # DNS
    mkdir -p $SRV/notebook/etc
    cat > $SRV/notebook/etc/hosts << EOF
127.0.0.1       localhost
$GITLABIP       ${PROJECT}-gitlab
EOF
    
    # LDAP
    mkdir -p $SRV/notebook/init
    $(ldap_makeconfig notebook)
    cp scripts/jupyter_notebook_config.py scripts/jupyter_report_config.py  $SRV/notebook/etc/
        
    echo "#!/bin/sh
echo \"Configuring LDAP...\"
chmod 0600 /etc/nslcd.conf
service nslcd start
    " > $SRV/notebook/init/0.sh
      
    # Start jupyter
    echo "#!/bin/sh
if [ -z \"\$REPORT\" ] ; then 
  echo \"Starting notebook for \$NB_USER...\"
  cd /home/\$NB_USER
  . start-notebook.sh --config=/etc/jupyter_notebook_config.py --log-level=DEBUG --NotebookApp.base_url=\$NB_URL --NotebookApp.port=\$NB_PORT
else
  echo \"Starting Report Server\"
  cd /report
  . start-report.sh --allow-root --config=/etc/jupyter_report_config.py --log-level=DEBUG --NotebookApp.base_url=\$NB_URL --NotebookApp.port=\$NB_PORT
fi
" \
      > $SRV/notebook/init/1.sh
    
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
