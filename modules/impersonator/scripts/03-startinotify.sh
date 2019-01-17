#! /bin/bash


CONF=/tmp/gitcommand.conf
LOG=/tmp/gitcommand.log
CMD=/usr/local/bin/init-ssh-agent.sh

if [ ! -x $CMD ] ; then
    echo "$CMD is not executable" > $LOG
    exit
fi

if [ -f $CONF ] ; then
   echo "Running mounter" >> $LOG
   $CMD
else
   echo "No config file, creating an empty so that inotifywait can attach to" >> $LOG
   touch $CONF
fi

(
while (true) ; do
    #NOTE: close_wait signal does not work in a docker container overlay fs.
    inotifywait  $CONF 2>> $LOG
    echo "Changes detected" >> $LOG

    while IFS=':' read -r USER KEY REPOHOST COMMAND <&3 ; do
	    #    #init-ssh-agent.sh steger /mnt/.volumes/home/steger/.ssh/github github.com /mnt/.volumes/git/github-github.com-steger-dobossbigpy/clone.sh 
        echo $CMD $USER $KEY $REPOHOST $COMMAND >> $LOG
        $CMD $USER $KEY $REPOHOST $COMMAND
    done 3< $CONF

done
) &
  
echo "inotifywait loop for ${CONF} is in background." >> $LOG

