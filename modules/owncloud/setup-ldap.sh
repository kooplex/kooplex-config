#chown root config/config.php

#INSTALL
./occ maintenance:install --admin-user "compare-admin" --admin-pass "almafa137"
#sudo -u www-data php occ maintenance:install --database "mysql" --database-name "owncloud"  --database-user "root" --database-pass "password" --admin-user "admin" --admin-pass "password"

chown root config/config.php

#ENABLE AND CONFIGURE LDAP
./occ app:enable user_ldap
./occ ldap:create-empty-config
dummy=`./occ ldap:create-empty-config`
LDAP_ID=`echo ${dummy#*configID}| sed -e "s/'//g"`
./occ ldap:set-config $LDAP_ID ldapAgentName "cn=admin,dc=127,dc=0,dc=0,dc=1"
./occ ldap:set-config $LDAP_ID ldapBase "dc=127,dc=0,dc=0,dc=1"
./occ ldap:set-config $LDAP_ID ldapBaseGroups "dc=127,dc=0,dc=0,dc=1"
./occ ldap:set-config $LDAP_ID ldapBaseUsers "dc=127,dc=0,dc=0,dc=1"
./occ ldap:set-config $LDAP_ID ldapHost 172.20.0.3
./occ ldap:set-config $LDAP_ID ldapAgentPassword almafa137
./occ ldap:set-config $LDAP_ID ldapPort 389
./occ ldap:set-config $LDAP_ID ldapLoginFilter "(&(|(objectclass=inetOrgPerson))(uid=%uid))"
./occ ldap:set-config $LDAP_ID ldapUserDisplayName displayname
./occ ldap:set-config $LDAP_ID ldapUserFilterObjectclass inetOrgPerson
./occ ldap:set-config $LDAP_ID ldapEmailAttribute mail
./occ ldap:set-config $LDAP_ID ldapUserFilter "(|(objectclass=inetOrgPerson))"
./occ ldap:set-config $LDAP_ID hasMemberOfFilterSupport ""
./occ ldap:set-config $LDAP_ID homeFolderNamingRule attr:uid
./occ ldap:set-config $LDAP_ID ldapExpertUsernameAttr "uid"
./occ ldap:set-config $LDAP_ID ldapConfigurationActive 1

#export OC_PASS="almafa137"; ./occ user:add --password-from-env --display-name owncloud-admin owncloud-admin --group="admin"
#./occ user:enable owncloud-admin

./occ app:enable files_external
export dum=`./occ files_external:create "/Files" "\OC\Files\Storage\Local" "null::null"`
export MOUNTID=`echo ${dum#*with id}`
./occ files_external:config $MOUNTID datadir "/home/\$user/files"

perl -pi -e 's/localhost/157.181.172.106:90/g' config/config.php

chown www-data config/config.php

