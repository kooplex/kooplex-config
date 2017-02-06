#!/bin/bash

case $VERB in
  "build")
    echo "Building image kooplex-owncloud"

    docker $DOCKERARGS build -t kooplex-owncloud .
  ;;
  "install")
    echo "Installing owncloud $PROJECT-owncloud [$OWNCLOUDIP]"
    
	mkdir -p $OWNCLOUDPATH/etc
    mkdir -p $OWNCLOUDPATH/data
    
    # Create owncloud container. We need to setup ldap as well
    docker $DOCKERARGS create \
      --name $PROJECT-owncloud \
      --hostname $PROJECT-owncloud \
      --net $PROJECT-net \
      --ip $OWNCLOUDIP \
      --volumes-from $PROJECT-home \
	  -v $OWNCLOUDPATH/etc:/etc/owncloud \
      -v $OWNCLOUDPATH/data:/var/www/html/data \
      kooplex-owncloud
  ;;
  "start")
    echo "Starting owncloud $PROJECT-owncloud [$OWNCLOUDIP]"
    docker $DOCKERARGS start $PROJECT-owncloud
  ;;
  "init")
    # Generate install file to be executed when the container starts for the first time
    LDAPPASS=$(getsecret ldap)
    OWNCLOUDPASS=$(getsecret owncloud)
	
	# Create mysql database and user for owncloud
	mysql_exec "CREATE DATABASE owncloud;"
	mysql_exec "CREATE USER owncloud IDENTIFIED BY '$OWNCLOUDPASS';"
	mysql_exec "GRANT ALL ON owncloud.* TO 'owncloud'@'%';"
	
	echo "Creating OwnCloud admin user..."
	adduser owncloudadmin OwnCloud Admin "owncloud-admin@$DOMAIN" "$OWNCLOUDPASS" 10002

	# Generate install scripts
	cat << EOF > $OWNCLOUDPATH/etc/install.sh
tar cf - --one-file-system -C /usr/src/owncloud . | tar xf -
chown -R www-data /var/www/html
EOF
	
	cat << EOF > $OWNCLOUDPATH/etc/init.sh
pushd /var/www/html

./occ maintenance:install --admin-user "owncloudadmin" --admin-pass "$OWNCLOUDPASS" \\
  --database "mysql" --database-host "$MYSQLIP" --database-name "owncloud" \\
  --database-user "owncloud" --database-pass "$OWNCLOUDPASS"
  

./occ config:system:set overwritewebroot --value '/owncloud'
./occ config:system:set overwritehost --value '$EXTERNALHOST'
./occ config:system:set overwrite.cli.url --value  '$OWNCLOUDIP'
./occ config:system:set trusted_domains 0 --value  'localhost'
./occ config:system:set trusted_domains 2 --value  '$OWNCLOUDIP'
./occ config:system:set trusted_domains 3 --value  '$NGINXIP'
./occ config:system:set trusted_proxies --value "[$OWNCLOUDIP,$NGINXIP]"

# Delete predefined folders, don't need them for science
rm -r core/skeleton/Photos/ core/skeleton/Documents/

# Enable LDAP plugin
./occ app:enable user_ldap

# Create a dummy config first, then use the second
./occ ldap:create-empty-config
#CONFIGID=\`./occ ldap:create-empty-config | sed -En "s/.*'(.+)'/\1/p"\`

./occ ldap:set-config "" ldapAgentName "cn=admin,$LDAPORG"
./occ ldap:set-config "" ldapBase "$LDAPORG"
./occ ldap:set-config "" ldapBaseGroups "$LDAPORG"
./occ ldap:set-config "" ldapBaseUsers "$LDAPORG"
./occ ldap:set-config "" ldapHost $LDAPIP
./occ ldap:set-config "" ldapAgentPassword $LDAPPASS
./occ ldap:set-config "" ldapPort 389
./occ ldap:set-config "" ldapLoginFilter "(&(|(objectclass=inetOrgPerson))(uid=%uid))"
./occ ldap:set-config "" ldapUserDisplayName displayname
./occ ldap:set-config "" ldapUserFilterObjectclass inetOrgPerson
./occ ldap:set-config "" ldapEmailAttribute mail
./occ ldap:set-config "" ldapUserFilter "(|(objectclass=inetOrgPerson))"
./occ ldap:set-config "" hasMemberOfFilterSupport ""
./occ ldap:set-config "" homeFolderNamingRule attr:uid
./occ ldap:set-config "" ldapExpertUsernameAttr "uid"
./occ ldap:set-config "" ldapConfigurationActive 1

# Configure external storage to link files from home directory
./occ app:enable files_external
./occ files_external:create "/Data" "\\OC\\Files\\Storage\\Local" "null::null"
./occ files_external:config "1" datadir "/home/\\\$user/Data"

# Create cron job to periodically re-scan user directories for changes
# TODO: substitute this with a more elaborate fam setup later
# TODO: remove if not necessary for external files, we won't have local files

#  m h  dom mon dow   command

#line="*/2 * * * * /var/www/html/occ files:scan --all"
#(crontab -u www-data -l; echo "$line" ) | crontab -u www-data -

popd

EOF

	docker $DOCKERARGS exec $PROJECT-owncloud /bin/bash /etc/owncloud/install.sh
	docker $DOCKERARGS exec $PROJECT-owncloud sudo -u www-data /bin/bash /etc/owncloud/init.sh
  ;;
  "stop")
    echo "Stopping owncloud $PROJECT-owncloud [$OWNCLOUDIP]"
    docker $DOCKERARGS stop $PROJECT-owncloud
  ;;
  "remove")
    echo "Removing owncloud $PROJECT-owncloud [$OWNCLOUDIP]"	
    docker $DOCKERARGS rm $PROJECT-owncloud
  ;;
  "purge")
    echo "Purging owncloud $PROJECT-owncloud [$OWNCLOUDIP]"
	
	# Delete mysql database and user
	# TODO: at this point mysql is usually stopped.
	# figure out where to put this, if anywhere
	# mysql_exec "DROP USER owncloud;"
	# mysql_exec "DROP DATABASE owncloud;"
	
	# Clean up directory
	rm -R -f $OWNCLOUDPATH
  ;;
  "clean")
    echo "Cleaning base image kooplex-owncloud"
    docker $DOCKERARGS rmi kooplex-owncloud
  ;;
esac
