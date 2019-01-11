#! /bin/bash
# Author: József Stéger
# Summary: Remount volumes in the proper folderstructure

set -v

exec >> /tmp/mount.log
exec 2>&1

date

#FIXME: start script should write pid in pidfile and we read it. Now command is hardcoded for jupyter
JUPYTERPID=$(ps axu | awk '/bash.*cd.*env.*jupyter/ { print $2; exit}')
echo "Server PID: $JUPYTERPID" >&2

ROOTDIR=/home/
EMPTYDIR=/tmp/.empty
VOLDIR=/mnt/.volumes

CONF=/tmp/mount.conf
_CONF=/tmp/.mount.conf

function do_rmdir () {
    # Remove folder and parent if empty
    dir=$1
    rmdir $1
    parent=$(dirname $dir)
    if [ -z "$(ls -A $parent)" ] ; then
        rmdir $parent
    fi
}

function do_umount () {
    dir=$1
    # kill any process related to mount
    echo "Killing..." >&2    
    lsof -Fp +d $dir | \
      awk '/^p([[:digit:]]+)$/ { print "kill -9 "gensub("p", "", 1, $0) }' | \
      tee -a /dev/stderr | \
      /bin/bash
    # umount
    echo "Umounting $dir" >&2
    /bin/umount $dir
    do_rmdir $dir
}

# Make sure configuration file is present
if [ ! -f $CONF ]; then
    echo "ERROR: Missing $CONF" >&2
    exit 1
fi

# See what is already mounted
echo "Bound folders" >&2
/bin/mount -l | \
  awk -v p=$ROOTDIR '($3 ~ p) { print $3 }' | \
  tee $_CONF

# Umount hider
if [ -z "$(ls -A $VOLDIR)" ] ; then
    umount $VOLDIR
else
    echo "ERROR: $VOLDIR not empty" >&2
fi
echo Showing $VOLDIR

# Mount new volumes
while IFS=':' read -r vol dir <&3 ; do
    src=$VOLDIR/$vol/$dir
    dst=$(echo $ROOTDIR/$vol/$dir | sed s,//*,/,g)
    if [ ! -d $src ] ; then
        echo "ERROR: Missing $src" >&2
        continue
    fi
    if [ -n "$(grep $dst $_CONF)" ] ; then
        echo "Already mounted $src -> $dst" >&2
        sed -i "s,$dst.*,," $_CONF
        continue
    else
        echo "Mounting $src -> $dst" >&2
        mkdir -p $dst
    fi
    /bin/mount -o bind $src $dst
done 3< $CONF

# get rid of home
dst=$(echo $ROOTDIR/$NB_USER | sed s,//*,/,g)
sed -i "s,$dst.*,," $_CONF

# Umount unused voulumes
if [ $(grep -v "^$" _CONF | wc -c) -gt 0 ] ; then
    echo "Stop service" >&2
    kill -SIGSTOP $JUPYTERPID
    for dir in $(cat $_CONF) ; do
        echo "Umounting $dir" >&2
        do_umount $dir
    done
    echo "Continue service" >&2
    kill -SIGCONT $JUPYTERPID
fi

# hide volumes from the user
mount -o bind $EMPTYDIR $VOLDIR
echo Hid $VOLDIR >&2

