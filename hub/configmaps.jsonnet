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
            name: 'startupscripts',
            namespace: Config.ns,
          },
          data: {
            nsswitch: 'sed -i -e "s,passwd.*,passwd: ldap compat systemd," -e "s,group.*,group: ldap compat systemd," /etc/nsswitch.conf\n',
            nslcd: '#! /bin/bash\n\n# We cannot mount this config file into /etc because it is not empty\nif [ -f /etc/mnt/nslcd.conf ] ; then\n  cat /etc/mnt/nslcd.conf > /etc/nslcd.conf\n  chmod 0600 /etc/nslcd.conf\nfi\n\nservice nslcd start\n',
            usermod: '#!/bin/bash\n\n\n# Change UID of NB_USER to NB_UID if it does not match \nif [ "$NB_UID" != $(id -u $NB_USER) ] ; then\n   usermod -u $NB_UID $NB_USER\nfi\n',
            pip: 'pip install debugpy==1.5.1\n',
            celery_beat: '#! /bin/bash\nL=/var/log/hub/celery_beat.log\nexec 1>> $L\nexec 2>&1\ncd /kooplexhub/kooplexhub/\nwhile (true) ; do\n python3 -m celery -A kooplexhub beat --scheduler django_celery_beat.schedulers:DatabaseScheduler\n echo "sleep for 10 secs"\n sleep 10\ndone &',
            celery_worker: '#! /bin/bash\nL=/var/log/hub/celery_worker.log\nexec 1>> $L\nexec 2>&1\ncd /kooplexhub/kooplexhub/\nwhile (true) ; do\n python3 -m celery -A kooplexhub worker\n echo "sleep for 10 secs"\n sleep 10\ndone &',
            sshstart: 'service ssh start\n',
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
        {
          apiVersion: 'v1',
          kind: 'ConfigMap',
          metadata: {
            name: 'authorizedkeys',
            namespace: Config.ns,
          },
          data: {
            authorizedkeys: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFfcxwYZwgA0ryHc6BTGS4LJ59hsNfHnnfTw8RDj/5x/mjDOxBtjwwvWz9jLb6ktezPSWt/fJCu2B18ZAkfXuz1p4JAQcuBPG21z+9rhVUPL5L4Gv1xcLrixzjlFmg2G18kpEO+wSlBiy/fbzvZY4428PpBQyUcKBx19Ati/maRzDha1jE1FYYd8cl+AbGgnHLszcyrnVgkzkTTXLh2nxf44NrT9qRNDd00bcLin0ZcmzyoPuY7/yS1Y/ymtloXSH6Un0SQmxp4FwjhIAR78ZSYRrvhObw3Fa7aD8S3zX3XdJMWkXNZmMWJjFJYtJmgMQnD2MGWy17bvTECuXyv62uJwed1iW7eN5XmoM1a6z5USriwTRRy/Uc8/ldT5RKFMzcMfoyyeUtXkjJGNgBxdE5K7zGz7N7owkc4cnPAGzBIx563yVcoUt8+xxlnXpO8ILpAlic/OdPmIHvnyivOi20G9rd2Itb6uopJmngUMb0B9qF9OMa/xu2o3sveCBdpCM= socialepoque@MacBook-Air-de-Social.local\nssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSdxxtB9PTiBZKyNXELvw7/CZQiekPRY7ykCiVDkkxNvjuvbDIcBqHMCW7RdVq5apGZxgflSdv9lERpU04jkxz/Qx8lXiCc7ZexRQRp8A5voCHDR2j7EqROJJVCwawk9Vf8QwkVsH4dKXmpLnOEE4yvTb9N5nnKxJpg1YOxL5+xREuQqcXWGNYZ92BY9BKZnbVZ7iupgF+e8K4SsdiRH6FEFtRZJsiE7cv7NcXkn0mxH1Y/R2O/4yhy/P1L3LK9UyiE+riecwDhJZ1y9YsTlvc5iZ46tZvPjdrsrbuILTaVQmkDunct+jxkuYEUgq1GC0Zy2CPWoxzfAelOjt60jN9 jegesm@work\nssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSK0lqeFrH56hBCA6qhMqkJBe6/ZvNXk68KeuGV3zc90Ptu4shfQQTFInUc8hM7jDbtYaLYbOp2a8bp8pvC88iH+IscmEdrpK3vktQ0vDBM510t+yD00CIjO+uDEVnjnoe2jv6rQJceEWDTDwEXlPSRciFgMUx242KPG0YFlAsH7CuWXffquJyUaXMTncLVQvUKo31FCGvcB7DC8LxUOWTuQfcJVCyKxJaGUQOTdDrFmNweGlU3WMOojakeVYSL+P3RilnSEUZtBPFdIBB4qEvLLgCiRd7EmYOKBuN20OqVG6jp46NnSG/yMMPjEJ6qPX0fEiO/UfhruOqPjniE7VT steger@agyalap\n',
          },
        },
      ],
  },
}
