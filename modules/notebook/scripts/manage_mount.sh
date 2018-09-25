# remount volumes in the proper folderstructure

case $1 in
  report|workdir|share)
    F=$1
  ;;
  *)
    echo "$0 <report|workdir|share>" >&2
    exit 1
  ;;
esac

TARGETDIR=/home/$NB_USER/$F
EMPTYDIR=/tmp/.empty
VOLDIR=/mnt/.volumes

CONF=/tmp/mount_${F}.conf

if [ -f $CONF ]; then

  umount $VOLDIR
  echo Showing $VOLDIR >&2

  while IFS=':' read -r task dir1 dir2 <&3 ; do
    if [ $task = '-' ] ; then
      udir=$TARGETDIR/$dir1
      if [ -d $udir ] ; then
        umount $udir
        echo Umounted $udir >&2
        rmdir $udir
        echo Removed $udir >&2
      fi
    elif [ $task = '+' ] ; then
      sdir=$dir1
      tdir=$TARGETDIR/$dir2
      if [ ! -d $sdir ] ; then
        echo "Source $sdir does not exist" >&2
        continue
      fi
      if [ -d $tdir ] ; then
        echo Exists $tdir >&2
        umount $tdir
        echo Umounted $tdir >&2
      else
        mkdir -p $tdir
        echo Created $tdir >&2
      fi
      mount -o bind $sdir $tdir
      echo Mounted $tdir >&2
    fi
  done 3< $CONF

  # hide volumes from the user
  mount -o bind $EMPTYDIR $VOLDIR
  echo Hid $VOLDIR >&2
fi

