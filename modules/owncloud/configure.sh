#!/bin/bash

case $VERB in
  "build")
    echo "Building image kooplex-owncloud"
    

#SECRET=$(getsecret ldap)
SECRET=$DUMMYPASS

cat << EOF > setup-ldap.sh
#chown root config/config.php

#INSTALL
./occ maintenance:install --admin-user "$PROJECT-admin" --admin-pass "$SECRET"
#sudo -u www-data php occ maintenance:install --database "mysql" --database-name "owncloud"  --database-user "root" --database-pass "password" --admin-user "admin" --admin-pass "password"

chown root config/config.php

#ENABLE AND CONFIGURE LDAP
./occ app:enable user_ldap
./occ ldap:create-empty-config
dummy=\`./occ ldap:create-empty-config\`
LDAP_ID=\`echo \${dummy#*configID}| sed -e "s/'//g"\`
./occ ldap:set-config \$LDAP_ID ldapAgentName "cn=admin,$LDAPORG"
./occ ldap:set-config \$LDAP_ID ldapBase "$LDAPORG"
./occ ldap:set-config \$LDAP_ID ldapBaseGroups "$LDAPORG"
./occ ldap:set-config \$LDAP_ID ldapBaseUsers "$LDAPORG"
./occ ldap:set-config \$LDAP_ID ldapHost $LDAPIP
./occ ldap:set-config \$LDAP_ID ldapAgentPassword $SECRET
./occ ldap:set-config \$LDAP_ID ldapPort 389
./occ ldap:set-config \$LDAP_ID ldapLoginFilter "(&(|(objectclass=inetOrgPerson))(uid=%uid))"
./occ ldap:set-config \$LDAP_ID ldapUserDisplayName displayname
./occ ldap:set-config \$LDAP_ID ldapUserFilterObjectclass inetOrgPerson
./occ ldap:set-config \$LDAP_ID ldapEmailAttribute mail
./occ ldap:set-config \$LDAP_ID ldapUserFilter "(|(objectclass=inetOrgPerson))"
./occ ldap:set-config \$LDAP_ID hasMemberOfFilterSupport ""
./occ ldap:set-config \$LDAP_ID homeFolderNamingRule attr:uid
./occ ldap:set-config \$LDAP_ID ldapExpertUsernameAttr "uid"
./occ ldap:set-config \$LDAP_ID ldapConfigurationActive 1

./occ app:enable files_external
export dum=\`./occ files_external:create "/Data" "\\OC\\Files\\Storage\\Local" "null::null"\`
export MOUNTID=\`echo \${dum#*with id}\`
./occ files_external:config \$MOUNTID datadir "/home/\\\$user/Data"

./occ config:system:set 'overwritewebroot' --value '/owncloud'
./occ config:system:set 'overwrite.cli.url' --value  '$OWNCLOUDIP'

#perl -pi -e "s/ 0 => 'localhost'/0 => 'localhost', 1 => '$DOMAIN',2 => '$NGINXIP',3 => '$OWNCLOUDIP'/g" config/config.php

./occ config:system:set trusted_domains 0 --value  'localhost'
./occ config:system:set trusted_domains 1 --value  '$OWNCLOUDIP'
./occ config:system:set trusted_domains 2 --value  '$NGINXIP'
./occ config:system:set trusted_domains 3 --value  '$OUTERHOST'
./occ config:system:set trusted_domains 4 --value  '$DOMAIN'

./occ config:system:set 'trusted_proxies' --value "[$OWNCLOUDIP,$NGINXIP]"
./occ config:system:set 'overwritehost' --value '$OUTER_DOMAIN'

rm -r core/skeleton/Photos/ core/skeleton/Documents/

chown www-data config/config.php

EOF


    docker $DOCKERARGS build -t kooplex-owncloud .
#docker pull owncloud
  ;;
  "install")
    echo "Installing owncloud $PROJECT-owncloud [$OWNCLOUDIP]"

    if [ ! -d $SRV/ownCloud/ ]; then 
      echo "OwnCloud database needs to be created!"; 
      mkdir -p $SRV/ownCloud/;
    else
      echo "OwnCloud database exists!";
    fi
    
    echo "OwnCloud database is in $SRV/ownCloud/";
    
    # Create owncloud container. We need to setup ldap as well
    docker $DOCKERARGS create \
      --name $PROJECT-owncloud \
      --hostname $PROJECT-owncloud \
      --net $PROJECT-net \
      --ip $OWNCLOUDIP \
      -v $SRV/ownCloud/:/var/www/html/data \
      -v $SRV/home/:/home \
      --privileged \
            kooplex-owncloud
#       owncloud

  ;;
  "start")
  #
  docker $DOCKERARGS start $PROJECT-owncloud
  ;;
  "init")

#MOUNT EVERYONES OWNCLOUD DIR

    
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
	rm -R -f $SRV/ownCloud
  ;;
  "clean")
    echo "Cleaning base image kooplex-owncloud"
    docker $DOCKERARGS rmi kooplex-owncloud
  ;;
esac
