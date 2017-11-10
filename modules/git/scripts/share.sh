#! /bin/bash

USER=$(whoami)
URL_API=http://kooplex-nginx/ownCloud/ocs/v1.php/apps/files_sharing/api/v1/shares

case $1 in
  share)
    curl --user ${USER}:$(awk '/^password/ {print $2}' ~/.netrc) ${URL_API} --data "path=/${2}&shareType=0&permissions=15&name=${2}&shareWith=${3}&publicUploads=false"
    ;;
  unshare)
    curl --user ${USER}:$(awk '/^password/ {print $2}' ~/.netrc) -X DELETE ${URL_API}/$(curl --user ${USER}:$(awk '/^password/ {print $2}' ~/.netrc) ${URL_API}?path=${2} | awk "/<element>/ { id = \"\" } /<id>.*<\/id>/ { id = \$0 } /<share_with>${3}<\/share_with>/ && (id) { print id }" | sed -e "s/^.*<id>//" -e "s/<.*//")            
    ;;
  *)
    echo "Ooops" >&2
esac

