# remount volumes in the proper folderstructure

mkdir -p /tmp/.empty
mount -t tmpfs tmpfs -o size=1K /home/
mkdir -p /home/${NB_USER}
mount -o bind /mnt/.volumes/home/${NB_USER} /home/${NB_USER}
echo "Home mounted for ${NB_USER}"

# hide volumes from the user
mount -o bind /tmp/.empty /mnt/.volumes
echo "Mount folder is hidden"
