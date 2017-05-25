LDAP initialization scripts and LDIF files

It doesn't contain the organisation and admin setting because they are automatically created by the docker image when the image is started for the first time. The command-line syntax to initialize settings is

	# docker run -d --net testnet -p 666:389 --name compare-ldap -v /data/data1/compare/srv/ldap/etc:/etc/ldap -v /data/data1/compare/srv/ldap/var:/var/lib/ldap -e SLAPD_PASSWORD=alma -e SLAPD_CONFIG_PASSWORD=alma -e SLAPD_DOMAIN=compare.vo.elte.hu dinkel/openldap

# Ldap schema extension with project meta

## Configuration

**Note**

Useful links:

* https://help.ubuntu.com/lts/serverguide/openldap-server.html
* http://www.openldap.org/doc/admin24/schema.html

Everything is manually set in a sandbox for now. At `novo1` a new container is running for this purpose.

```bash
docker run -it --name kooplex_ldap_newschema ubuntu bash
```

In the container:

```bash
apt update
apt install slapd ldap-utils vim ssh-client
service slapd start
dpkg-reconfigure slapd
```

A trivial password is set for the slapd administrator. The parameters set when reconfiguration:

```
 no
 novo1.complex.elte.hu
 novo1.complex.elte.hu
 x
 x
 2
 no
 no
 no
```

## Add content

Dump ldap content from within the `kooplex-hub` container and transfer dumps in the container
```bash
ldapsearch -x -H ldap://compare-ldap -W -D cn=admin,dc=novo1,dc=complex,dc=elte,dc=hu -b ou=users,dc=novo1,dc=complex,dc=elte,dc=hu -s one "objectclass=top" | ssh jozsi@192.168.122.10 cat \- \> /tmp/u.ldif
ldapsearch -x -H ldap://compare-ldap -W -D cn=admin,dc=novo1,dc=complex,dc=elte,dc=hu -b ou=groups,dc=novo1,dc=complex,dc=elte,dc=hu -s one "objectclass=top" | ssh jozsi@192.168.122.10 cat \- \> /tmp/g.ldif
```


Initialize ldap with the current kooplex entries.

```bash
ldapadd -x -D cn=admin,dc=novo1,dc=complex,dc=elte,dc=hu -W << EOF
dn: ou=users,dc=novo1,dc=complex,dc=elte,dc=hu
objectClass: organizationalUnit
ou: users

dn: ou=groups,dc=novo1,dc=complex,dc=elte,dc=hu
objectClass: organizationalUnit
ou: Groups
EOF

ldapadd -x -D cn=admin,dc=novo1,dc=complex,dc=elte,dc=hu -W -f ~t/u.ldif
ldapadd -x -D cn=admin,dc=novo1,dc=complex,dc=elte,dc=hu -W -f ~t/g.ldif
```

## Define the new project schema

```bash
cat > project.schema << EOF
attributeType ( 1.3.6.1.4.1.42.1.1
    NAME 'projectName'
    DESC 'The name of the project'
    EQUALITY caseIgnoreMatch
    SUBSTR caseIgnoreSubstringsMatch
    SINGLE-VALUE
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{32768} )
attributeType ( 1.3.6.1.4.1.42.1.2
    NAME 'projectDescription'
    DESC 'The description of the project'
    EQUALITY caseIgnoreMatch
    SUBSTR caseIgnoreSubstringsMatch
    SINGLE-VALUE
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{32768} )
attributeType ( 1.3.6.1.4.1.42.1.3
    NAME 'creatorUid'
    DESC 'The user id of the project creator'
    EQUALITY integerMatch
    SINGLE-VALUE
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
attributeType ( 1.3.6.1.4.1.42.1.4
    NAME 'adminUid'
    DESC 'The user id of the project administrator(s)'
    EQUALITY integerMatch
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
attributeType ( 1.3.6.1.4.1.42.1.5
    NAME 'memberGid'
    DESC 'The group id of the project member(s)'
    EQUALITY integerMatch
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
attributeType ( 1.3.6.1.4.1.42.1.6
    NAME 'mntDescription'
    DESC 'Meta information of the storage'
    EQUALITY caseIgnoreMatch
    SUBSTR caseIgnoreSubstringsMatch
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{32768} )

objectclass ( 1.3.6.1.4.1.42.2.1 NAME 'kooplexProject'
    DESC 'Project binding'
    STRUCTURAL
    SUP organizationalUnit
    MUST ( projectName $ projectDescription $ creatorUid $ adminUid )
    MAY ( memberGid $ mntDescription ) ) 
EOF

ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config dn
```

According to the current schema structure create a configuration file for the extension.

```bash
cat > schema_convert.conf << EOF
include /etc/ldap/schema/core.schema
include /etc/ldap/schema/cosine.schema
include /etc/ldap/schema/nis.schema
include /etc/ldap/schema/inetorgperson.schema
include /root/project.schema
EOF

mkdir ldif_output
slapcat -f schema_convert.conf -F ldif_output -n 0 | grep project,cn=schema
```

Make sure to include the proper identifier for the converter (4 in this case)

```bash
slapcat -f schema_convert.conf -F ldif_output -n0 -H ldap:///cn={4}project,cn=schema,cn=config -l cn=project.ldif
```

Edit the file `project.ldif`. Remove `{4}` and the tail from the line **structuralObjectClass: olcSchemaConfig**.

Propagate the new schema and confirm it went well:

```bash
ldapadd -Q -Y EXTERNAL -H ldapi:/// -f cn\=project.ldif

ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config dn
```

Create the root

```bash
ldapadd -x -D cn=admin,dc=novo1,dc=complex,dc=elte,dc=hu -W << EOF
dn: ou=projects,dc=novo1,dc=complex,dc=elte,dc=hu
objectClass: organizationalUnit
ou: projects
EOF
```


## Add new project instances

```bash
ldapadd -x -D cn=admin,dc=novo1,dc=complex,dc=elte,dc=hu -W << EOF
idn: uid=testproject-steger,ou=projects,dc=novo1,dc=complex,dc=elte,dc=hu
ou: projects,dc=novo1,dc=complex,dc=elte,dc=hu
objectClass: top
objectClass: kooplexProject
objectClass: posixAccount
objectClass: shadowAccount
projectName:  testproject
cn: testproject-steger
projectDescription: "This is a test project description"
creatorUid: 10025
adminUid: 10025
memberGid: 10025
memberGid: 10003
mntDescription: oc:testproject-steger
uidNumber: 11001
gidNumber: 10025
homeDirectory: /dev/null
EOF
```

## Test

Check if everything is alright by browsing content.

```bash
ldapsearch -x -LLL -H ldap:/// -b dc=novo1,dc=complex,dc=elte,dc=hu dn
```


_cut here_
ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=config dn
