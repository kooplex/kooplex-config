# IN ORDER TO BE ABLE TO USE TERMINALS
# AND HAVE THE RIGHT WORKING DIRECTORY IN RSTUDIO

Target=home/$NB_USER/.rstudio/monitored/user-settings/
File=/etc/rstudio/user-settings
if [ ! -d $Target ]; then
     echo "Copying initial user settings in user's folder"
     mkdir -p $Target
     cp $File $Target
     chown $NB_USER:$NBUSER -R home/$NB_USER/.rstudio
fi
