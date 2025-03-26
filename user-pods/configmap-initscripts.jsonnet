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
            namespace: Config.nspods,
          },
          data: {
            nsswitch: 'sed -i -e "s,passwd.*,passwd: ldap compat systemd," -e "s,group.*,group: ldap compat systemd," /etc/nsswitch.conf\n',
            nslcd: '#! /bin/bash\n\n# We cannot mount this config file into /etc because it is not empty\nif [ -f /etc/mnt/nslcd.conf ] ; then\n  cat /etc/mnt/nslcd.conf > /etc/nslcd.conf\n  chmod 0600 /etc/nslcd.conf\nfi\n\nservice nslcd start\n',
            usermod: '#!/bin/bash\n\n\n# Change UID of NB_USER to NB_UID if it does not match \nif [ "$NB_UID" != $(id -u $NB_USER) ] ; then\n   usermod -u $NB_UID $NB_USER\nfi\n\n#  entrypoint: |\n#          #!/bin/sh\n#\n#          for SCRIPT in /init/*\n#          do\n#              if [ -x $SCRIPT ] ; then\n#                  echo "Running init script: $SCRIPT"\n#                  $SCRIPT\n#              elif [ -f $SCRIPT ] ; then\n#                  echo "Sourcing init script: $SCRIPT"\n#                  . $SCRIPT\n#              else\n#                  echo "Not a file $SCRIPT"\n#              fi\n#          done\n#          \n#          echo "Sleeping for infinity"\n#          exec sleep infinity\n',
            jobtools: '#!/bin/bash\n\necho "PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/etc/jobtool/" >> /etc/profile.d/02-jobtools.sh\nchmod a+x /etc/profile.d/02-jobtools.sh\n',
            //munge: 'groupmod munge -g 997; usermod munge -u 999; cp  /etc/munge_tmp/munge.key /etc/munge/munge.key; chown -R munge:munge /etc/munge; chown munge:munge /var/lib/munge; chown munge:munge -R /var/log/munge/; service munge start; ',
            teleport: 'teleport start -l $(hostname -i).${POD_NAMESPACE} --labels=teleport=${NB_USER} --roles=node    --token=$(printf "AUTH ${REDIS_PASSWORD}\\r\\nGET nodetoken\\r\\n" | nc -N redis.teleport 6379| tail -n1 | tr -dc \'[:alnum:]\') --ca-pin=sha256:7b2932827b1827cd309bb2b952a6062dd040341764a09f04c201afe9ee1e5f40     --auth-server=teleport.vo.elte.hu & unset REDIS_PASSWORD',
            ssh: '#! /bin/bash\nif [ -z "$REPORT_TYPE" ] ; then\n        if [ -z "$SSH_AUTH_SOCK" ] ; then\n                export SSH_AUTH_SOCK=/tmp/$NB_USER\n        fi\n        exec su $NB_USER -c "ssh-agent -a $SSH_AUTH_SOCK"\n        echo "ssh-agent started"\necho "VMI"\nelse\n        echo "ssh-agent not started"\nfi',
          },
        },
        {
          apiVersion: 'v1',
          kind: 'ConfigMap',
          metadata: {
            name: 'nslcd',
            namespace: Config.nspods,
          },
          data: {
            nslcd: 'uid nslcd\ngid nslcd\nuri ldap://' + Config.ldap.appname + '.' + Config.ldap.authns + ' ldap://' + Config.ldap.appname + '2.' + Config.ldap.authns + '\nbase ' + Config.ldap.base + '\nbinddn ' + Config.ldap.binddn + '\nbindpw ' + Config.ldap.pw + '\n' + (if Config.ldap.basegroup == '' then '' else 'base group ' + Config.ldap.basegroup) + '\ntls_cacertfile /etc/ssl/certs/ca-certificates.crt\n',
          },
        },
      ],
    },
}
