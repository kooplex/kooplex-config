#!/bin/bash

# Handle special flags if we're root
if [ $UID == 0 ] ; then

	echo " 1"

    # Change UID of NB_USER to NB_UID if it does not match
     
    #userid=`ldapsearch -x "(cn=jegesm)" | grep memberUid | awk '{print $2}'`
    if [ "$NB_UID" != $(id -u $NB_USER) ] ; then
#    if [ "$NB_UID" != $userid ] ; then
        usermod -u $NB_UID $NB_USER
        echo " 12"
#        chown -R $NB_UID $CONDA_DIR
        echo " 13"
    fi
	echo " 2"
    # Enable sudo if requested
    if [ ! -z "$GRANT_SUDO" ]; then
        echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
    fi
	echo " 3"

    # debug
    env

    # make sure project users are in the group associated with share folder
    addgroup --gid $(( $GID_OFFSET + $PR_ID )) $PR_NAME
    for username in $(echo $PR_MEMBERS | sed s/,/\ /g) ; do
        addgroup  $username $PR_NAME
    done

    echo "host key retieval"

    # host identification #FIXME: hardcoded
    GITLABHOST=$(grep gitlab /etc/hosts | awk '{ print $2 }')
echo 1
    ssh-keyscan -H $GITLABHOST > /tmp/gitlab.pub
echo 2
    USER_HOSTKEYS=/home/${NB_USER}/.ssh/known_hosts
echo 3
    cat /tmp/gitlab.pub $USER_HOSTKEYS | sort | uniq > /tmp/new
echo 4
    mv /tmp/new $USER_HOSTKEYS
echo 5
    chown ${NB_USER}:${NB_USER} $USER_HOSTKEYS

    echo "cloning"

    # git clone if it does not exist
    if [ ! -d /home/${NB_USER}/git/.git ] ; then
        echo exec su $NB_USER -c "eval \"\$(ssh-agent)\" && ssh-add \$HOME/.ssh/gitlab.key && git clone $PR_URL \$HOME/git"
        su $NB_USER -c "eval \"\$(ssh-agent)\" && ssh-add \$HOME/.ssh/gitlab.key && git clone $PR_URL \$HOME/git"
    else
        echo "$PR_URL already cloned..."
    fi

    # Start the notebook server
    exec su $NB_USER -c "env PATH=$PATH jupyter notebook $*"
    echo " masik 4"
else
    # Otherwise just exec the notebook
    exec jupyter notebook $*
    echo " masik 1"
fi

