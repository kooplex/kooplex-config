#!/bin/bash

# Handle special flags if we're root
if [ $UID == 0 ] ; then

	echo " 1"
    # Change UID of NB_USER to NB_UID if it does not match
    if [ "$NB_UID" != $(id -u $NB_USER) ] ; then
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

    # Start the notebook server
    exec su $NB_USER -c "env PATH=$PATH jupyter notebook $*"
    echo " masik 4"
    # nb-extension



else
    # Otherwise just exec the notebook
    exec jupyter notebook $*
    echo " masik 1"
fi

