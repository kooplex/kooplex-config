#! /bin/bash

USER=$(whoami)
URL_API=http://kooplex-nginx/ownCloud/ocs/v1.php/apps/files_sharing/api/v1/shares

#FIXME: URL PATTERN HARDCODED
PW=$(awk '/^http:..kooplex-nginx.ownCloud.remote.php.webdav./ {print $3}' ~/.davfs2/secrets)

case $1 in
  share)
    curl --user ${USER}:${PW} ${URL_API} --data "path=/${2}&shareType=0&permissions=15&name=${2}&shareWith=${3}&publicUploads=false"
    ;;
  unshare)
    curl --user ${USER}:${PW} -X DELETE ${URL_API}/$(curl --user ${USER}:${PW} ${URL_API}?path=${2} | awk "/<element>/ { id = \"\" } /<id>.*<\/id>/ { id = \$0 } /<share_with>${3}<\/share_with>/ && (id) { print id }" | sed -e "s/^.*<id>//" -e "s/<.*//")            
    ;;
  mkdir)
    [ -f oc/.notmounted ] && mount oc
    mkdir -p oc/${2}
    umount oc
    ;;
  *)
    echo "Ooops" >&2
esac
