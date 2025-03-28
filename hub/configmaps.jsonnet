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
            name: 'hubstartupscripts',
            namespace: Config.ns,
          },
          data: {
            aliases: 'alias tlog="tail -f /var/log/hub/hub.log"; alias llog="less /var/log/hub/hub.log"',
            nsswitch: 'sed -i -e "s,passwd.*,passwd: ldap compat systemd," -e "s,group.*,group: ldap compat systemd," /etc/nsswitch.conf\n',
            nslcd: '#! /bin/bash\n\n# We cannot mount this config file into /etc because it is not empty\nif [ -f /etc/mnt/nslcd.conf ] ; then\n  cat /etc/mnt/nslcd.conf > /etc/nslcd.conf\n  chmod 0600 /etc/nslcd.conf\nfi\n\nservice nslcd start\n',
            usermod: '#!/bin/bash\n\n\n# Change UID of NB_USER to NB_UID if it does not match \nif [ "$NB_UID" != $(id -u $NB_USER) ] ; then\n   usermod -u $NB_UID $NB_USER\nfi\n',
            sshstart: 'service ssh start\n',
            runqueue: '#! /bin/bash\nexec 2> /var/log/hub/queue.log\nexec 1>&2\ncd /kooplexhub/kooplexhub\n. /opt/python-packages/bin/activate && python3 manage.py djangohuey --queue container &;\n/opt/python-packages/bin/activate && python3 manage.py djangohuey --queue course &;\n/opt/python-packages/bin/activate && python3 manage.py djangohuey --queue hub & #sleep 10000',
            runserver: '#! /bin/bash\nexec 2> /var/log/hub/runserver.log\nexec 1>&2\ncd /kooplexhub/kooplexhub\n. /opt/python-packages/bin/activate && uwsgi -s /tmp/uwsgi.sock --uid 107 --gid 106 --wsgi-file kooplexhub/wsgi.py --daemonize\n #sleep 10000',
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
