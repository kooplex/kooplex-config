# CREATE rserver.conf and rsession.conf
cat << EOF > /etc/rstudio/rserver.conf
server-user=rstudio
rsession-which-r=/usr/local/bin/R
server-working-dir=/home
rsession-config-file=/home/$NB_USER
EOF

cat << EOL > /etc/rstudio/rsession.conf
user-identity=$NB_USER
allow-terminal-websockets=0
session-default-working-dir=/home
EOL

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
