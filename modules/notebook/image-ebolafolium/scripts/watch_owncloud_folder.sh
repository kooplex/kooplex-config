USER=tmp_twouser
DIR=/home/$NB_USER/$USER
TARGET=http://compare.vo.elte.hu/owncloud/remote.php/webdav/

mkdir -p $DIR

inotifywait -m $DIR  -e create -e moved_to --exclude ".csync_journal.db"|
while read path action file; do
        echo "The file '$file' appeared in directory '$path' via '$action'"
       # do something with the file
#        owncloudcmd --user $NB_USER --password almafa137 $DIR $TARGET
        owncloudcmd --user \USER  --password almafa137 $DIR $TARGET
	sleep 3
done
