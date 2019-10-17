# remount volumes in the proper folderstructure

mkdir -p /tmp/.empty
mount -t tmpfs tmpfs -o size=1K /home/
mkdir -p /home/${NB_USER}
if [ -z "$REPORT_DIR" ]; then
        mount -o bind /mnt/.volumes/home/${NB_USER} /home/${NB_USER}
else
        mkdir /mnt/report_temp/
        mount -o bind /mnt/report_temp/ /home/$NB_USER
        chmod a+wrx /home/$NB_USER
        mkdir /home/report
        mount -o bind /mnt/.volumes/report/$NB_USER /home/report/
fi

echo "Home mounted for ${NB_USER}"

# hide volumes from the user
mount -o bind /tmp/.empty /mnt/.volumes
echo "Mount folder is hidden"
