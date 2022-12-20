local Config = import '../config.libsonnet';

{
  'configmaps.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
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
            usermod: '#!/bin/bash\n\n\n# Change UID of NB_USER to NB_UID if it does not match \nif [ "$NB_UID" != $(id -u $NB_USER) ] ; then\n   usermod -u $NB_UID $NB_USER\nfi\n',
            //            pip: 'pip install debugpy==1.5.1\n',
            celery_beat: '#! /bin/bash\nL=/var/log/hub/celery_beat.log\nexec 1>> $L\nexec 2>&1\ncd /kooplexhub/kooplexhub/\nwhile (true) ; do\n python3 -m celery -A kooplexhub beat --scheduler django_celery_beat.schedulers:DatabaseScheduler\n echo "sleep for 10 secs"\n sleep 10\ndone &',
            celery_worker: '#! /bin/bash\nL=/var/log/hub/celery_worker.log\nexec 1>> $L\nexec 2>&1\ncd /kooplexhub/kooplexhub/\nwhile (true) ; do\n python3 -m celery -A kooplexhub worker\n echo "sleep for 10 secs"\n sleep 10\ndone &',
            //            sshstart: 'service ssh start\n',
            runserver: '#! /bin/bash\n\nexec 2> /var/log/hub/runserver.log\nexec 1>&2\n\n##FIXME: this is not nice\n#env > /var/spool/cron/crontabs/root\n#echo -e "*/1 * * * * /usr/bin/python3 /kooplexhub/kooplexhub/manage.py scheduler\\n" >> /var/spool/cron/crontabs/root\n#/etc/init.d/cron start\n\ncd /kooplexhub/kooplexhub/\n#git pull\n\n\nwhile (true) ; do\n  echo "Waiting for mysql server"\n  mysql -u $HUBDB_USER --password=$HUBDB_PW -h $HUBDB_HOSTNAME $HUBDB -e "SELECT 1"\n  [ $? = 0 ] && break\n  sleep 2\ndone\n\n/usr/bin/python3 manage.py runserver 0.0.0.0:80\n',
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
            nslcd: 'uid nslcd\ngid nslcd\nuri ldap://' + Config.ldap.appname + '.' + Config.ldap.authns + ' ldap://' + Config.ldap.appname + '2.' + Config.ldap.authns + '\nbase ' + Config.ldap.base + '\nbinddn ' + Config.ldap.binddn + '\nbindpw ' + Config.ldap.pw + '\n' + (if Config.ldap.basegroup == '' then '' else 'base group ' + Config.ldap.basegroup) + '\ntls_cacertfile /etc/ssl/certs/ca-certificates.crt\n',
          },
        },
      ],
  },
}
