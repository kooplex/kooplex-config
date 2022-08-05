local Config = import '../config.libsonnet';

{
  'configmaps.yaml-raw':
    {
      apiVersion: 'v1',
      kind: 'List',
      items: [
        {
          apiVersion: 'v1',
          kind: 'ConfigMap',
          metadata: {
            name: 'initscripts',
            namespace: Config.ns,
          },
          data: {
            nsswitch: 'sed -i -e "s,passwd.*,passwd: ldap compat systemd," -e "s,group.*,group: ldap compat systemd," /etc/nsswitch.conf\n',
            nslcd: '#! /bin/bash\n\n# We cannot mount this config file into /etc because it is not empty\nif [ -f /etc/mnt/nslcd.conf ] ; then\n  cat /etc/mnt/nslcd.conf > /etc/nslcd.conf\n  chmod 0600 /etc/nslcd.conf\nfi\n\nservice nslcd start\n',
            usermod: '#!/bin/bash\n\n\n# Change UID of NB_USER to NB_UID if it does not match \nif [ "$NB_UID" != $(id -u $NB_USER) ] ; then\n   usermod -u $NB_UID $NB_USER\nfi\n\n#  entrypoint: |\n#          #!/bin/sh\n#\n#          for SCRIPT in /init/*\n#          do\n#              if [ -x $SCRIPT ] ; then\n#                  echo "Running init script: $SCRIPT"\n#                  $SCRIPT\n#              elif [ -f $SCRIPT ] ; then\n#                  echo "Sourcing init script: $SCRIPT"\n#                  . $SCRIPT\n#              else\n#                  echo "Not a file $SCRIPT"\n#              fi\n#          done\n#          \n#          echo "Sleeping for infinity"\n#          exec sleep infinity\n',
            jobtools: '#!/bin/bash\n\necho "PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/etc/jobtools/" >> /etc/profile.d/02-jobtools.sh\nchmod a+x /etc/profile.d/02-jobtools.sh\n',
          },
        },
        {
          apiVersion: 'v1',
          kind: 'ConfigMap',
          metadata: {
            name: 'nslcd',
            namespace: Config.ns,
          },
          data: {
            nslcd: 'uid nslcd\ngid nslcd\nuri ldap://ldap-test.k8plex-test ldap://ldap-test2.k8plex-test\nbase dc=k8plex-test,dc=vo,dc=elte,dc=hu\nbinddn cn=admin,dc=k8plex-test,dc=vo,dc=elte,dc=hu\nbindpw ' + Config.ldap.pw + '\ntls_cacertfile /etc/ssl/certs/ca-certificates.crt\n',
          },
        },
      ],
    },
}
