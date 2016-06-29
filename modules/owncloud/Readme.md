
#Server side

We could probably configure LDAP from command line through
```bash
occ ldap:set-config ...
```


# Client side
To mount directoy from webdav we need to add davfs2 module to the notebook image
```bash
RUN apt-get install -y davfs2
```

Then include similar line to this in /etc/fstab
```bash
157.181.172.106:85/remote.php/dav/files/user/ /home/user/Adatok davfs user,rw,noauto 0 0
```

Need to create a secret file so that don't have to type username and password
```bash
chmod 0600 /home/user/.dav2fs/secrets
echo "157.181.172.106:85/remote.php/dav/files/user/ user almafa137" > /home/user/.dav2fs/secrets
```

Then simply mount with the (no sudo/root)
```bash
mount /home/user/Adatok
```