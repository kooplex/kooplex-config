#!/bin/bash

case $VERB in
  "build")
    echo "Building image $PREFIX-notebooks"

#    docker $DOCKERARGS build -t $PREFIX-notebook .
    
     mkdir -p $SRV/notebook/images
#     rm image-*/Dockerfile*~
     cp -r image-* $SRV/notebook/images/
     for imagedir in $SRV/notebook/images/image-*
     do
        docfile=$imagedir"/Dockerfile-"${imagedir#*image-}
     	echo $docfile $imagedir
        docker $DOCKERARGS build -f $docfile -t $PREFIX-notebook-${docfile#*Dockerfile-} $imagedir
       
     done

#http://polc.elte.hu/owncloud/remote.php/webdav /home/jeges6/own davfs user,rw,auto 0 0
#usermod -aG davfs2 jeges6
    
  ;;
  "install")
    echo "Installing notebook $PROJECT-notebook [$NOTEBOOKIP]"
    
    # LDAP
    mkdir -p $SRV/notebook/etc
    mkdir -p $SRV/notebook/init
    $(ldap_makeconfig notebook)
    cp jupyter_notebook_config.py $SRV/notebook/etc/
        
    echo "#/bin/sh
echo \"Configuring LDAP...\"
chmod 0600 /etc/nslcd.conf
service nslcd start
    " > $SRV/notebook/init/0.sh
      
    # Start jupyter
    echo "#/bin/sh
echo \"Starting notebook for \$NB_USER...\"
#cd /home/\$NB_USER
#cd /\$NB_USER
cd /home
. start-notebook.sh --config=/etc/jupyter_notebook_config.py --log-level=DEBUG --NotebookApp.base_url=\$NB_URL --NotebookApp.port=\$NB_PORT" \
      > $SRV/notebook/init/1.sh
    
    # TODO: we create a notebook container here for testing but
    # individual containers will later be created for single
    # users from python. Use python unit tests to create notebook container!
#    docker $DOCKERARGS create \
#      --name $PROJECT-notebook \
#      --hostname $PROJECT-notebook \
#      --net $PROJECT-net \
#      --ip $NOTEBOOKIP \
#      --privileged \
#      $(ldap_makebinds notebook) \
#      $(home_makebinds notebook) \
#      -v $SRV/notebook/etc/jupyter_notebook_config.py:/etc/jupyter_notebook_config.py \
#      -v $SRV/notebook/init:/init \
#      -e NB_USER=test \
#      -e NB_UID=10002 \
#      -e NB_GID=10002 \
#      -e NB_URL=/notebook/test/ \
#      -e NB_PORT=8000 \
#      $PREFIX-notebook
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
    docker $DOCKERARGS images |grep kooplex-notebook| awk '{print $1}' | xargs -n  1 docker $DOCKERARGS rmi
  ;;
esac