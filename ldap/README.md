LDAP initialization scripts and LDIF files

It doesn't contain the organisation and admin setting because they are automatically created by the docker image when the image is started for the first time. The command-line syntax to initialize settings is

	# docker run -d --net testnet -p 666:389 --name compare-ldap -v /data/data1/compare/srv/ldap/etc:/etc/ldap -v /data/data1/compare/srv/ldap/var:/var/lib/ldap -e SLAPD_PASSWORD=alma -e SLAPD_CONFIG_PASSWORD=alma -e SLAPD_DOMAIN=compare.vo.elte.hu dinkel/openldap