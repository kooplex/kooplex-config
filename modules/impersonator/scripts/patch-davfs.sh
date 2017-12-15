#! /bin/bash


mv /etc/fstab /etc/fstab.old
getent passwd | cut -d: -f1,3 | while read l ; do
  uname=$(echo $l | cut -f1 -d:)
  uid=$(echo $l | cut -f2 -d:)
  [ $uid -le 10000 ] && continue
  [ $uname = nobody ] && continue
  [ $uname = gitlabadmin ] && continue
  echo "http://kooplex-nginx/ownCloud/remote.php/webdav/ /home/$uname/oc davfs user,rw,auto 0 0" >> /etc/fstab
  addgroup $uname davfs2
done 
