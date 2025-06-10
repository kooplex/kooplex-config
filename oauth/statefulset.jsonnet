local Config = import '../config.libsonnet';

{
 'statefulset.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
        {
         "apiVersion": "apps/v1",
         "kind": "StatefulSet",
         "metadata": {
            name: Config.oauth.appname,
           "namespace": Config.ns
         },
         "spec": {
           "serviceName": Config.oauth.appname,
           "podManagementPolicy": "Parallel",
           "replicas": 1,
           "selector": {
             "matchLabels": {
               "app": Config.oauth.appname
             }
           },
           "template": {
             "metadata": {
               "labels": {
                 "app": Config.oauth.appname
               }
             },
             "spec": {
               "initContainers": [
                 {
                   "name": "init-gitclone",
                   "image": "ajeetraina/alpine-git",
                   "command": [
                     "sh",
                     "-c",
                     "git clone https://github.com/kooplex/kooplex-oauth.git /x || true"
                   ],
                   "volumeMounts": [
                     {
                       "mountPath": "/x",
                       "name": "vol",
                       "subPath": Config.instance_subpath+Config.oauth.appname+"/_code_/"
                     }
                   ]
                 }
               ],
               "containers": [
                 {
                   "image": Config.oauth.image,
                   "lifecycle": {
                     "postStart": {
                       "exec": {
                         "command": [
                           "/bin/sh",
                           "-c",
                           "echo PS1=\\'\\\\[\\\\033\\[01\\;36m\\\\]\\\\u\\\\[\\\\033\\[00m\\\\]@\\\\[\\\\033\\[00\\;32m\\\\]\\\\h-dev\\\\[\\\\033\\[00m\\\\]: \\\\[\\\\033\\[01\\;33m\\\\]\\\\w\\\\[\\\\033\\[00m\\\\]\\\\$ \\' >> /root/.bashrc"
                         ]
                       }
                     }
                   },
                   "name": Config.oauth.appname,
                   "ports": [
                     {
                       "containerPort": 80,
                       "name": "http"
                     }
                   ],
                   "volumeMounts": [
                     {
                       "mountPath": "/srv",
                       "name": "vol",
                       "subPath": Config.instance_subpath+Config.oauth.appname+"/_code_/"
                     },
                     {
                       "mountPath": "/var/log/oauth",
                       "name": "vol",
                       "subPath": Config.instance_subpath+Config.oauth.appname+"/logs/"
                     }
                   ],
                   "env": [
                     {
                       "name": "DBROOT_PW",
                       "value": Config.oauth.dbrootpw
                     },
                     {
                       "name": "DB_HOSTNAME",
                       "value": Config.oauth.dbhostname
                     },
                     {
                       "name": "LANG",
                       "value": "en_US.UTF-8"
                     },
                     {
                       "name": "DJANGO_SECRET_KEY",
                       "value": Config.oauth.djangosecret
                     },
                     {
                       "name": "DB",
                       "value": Config.oauth.dbname
                     },
                     {
                       "name": "DB_USER",
                       "value": Config.oauth.dbuser
                     },
                     {
                       "name": "DB_PW",
                       "value": Config.oauth.dbpw
                     },
                     {
                       "name": "LDAP_PW",
                       "value": Config.ldap.pw
                     },
                     {
                       "name": "LDAP_URL",
                       "value": Config.ldap.appname
                     },
                     {
                       "name": "LDAP_BIND_DN",
                       "value": Config.ldap.binddn
                     },
                     {
                       "name": "LDAP_BASE_DN",
                       "value": Config.ldap.base
                     }
                   ]
                 }
               ],
               "volumes": [
                 {
                   "name": "vol",
                   "persistentVolumeClaim": {
                     "claimName": Config.nfsvol
                   }
                 }
               ]
             }
           }
         }
       },
       {
         "apiVersion": "apps/v1",
         "kind": "StatefulSet",
         "metadata": {
           "name": Config.oauth.dbhostname,
           "namespace": Config.ns
         },
         "spec": {
           "serviceName": Config.oauth.dbhostname,
           "podManagementPolicy": "Parallel",
           "replicas": 1,
           "selector": {
             "matchLabels": {
               "app": Config.oauth.dbhostname
             }
           },
           "template": {
             "metadata": {
               "labels": {
                 "app": Config.oauth.dbhostname
               }
             },
             "spec": {
               "containers": [
                 {
                   "image": "mariadb:10.5.4",
                   "name": Config.oauth.appname+"-db",
                   "ports": [
                     {
                       "containerPort": 3306,
                       "name": "mysql"
                     }
                   ],
                   "volumeMounts": [
                     {
                       "mountPath": "/var/lib/mysql",
                       "name": "vol",
                       "subPath": Config.instance_subpath+Config.oauth.appname+"/db/"
                     }
                   ],
                   "env": [
                     {
                       "name": "MYSQL_ROOT_PASSWORD",
                       "value": Config.oauth.dbrootpw
                     },
                     {
                       "name": "MYSQL_USER",
                       "value": Config.oauth.dbuser
                     },
                     {
                       "name": "MYSQL_PASSWORD",
                       "value": Config.oauth.dbpw
                     },
                     {
                       "name": "MYSQL_DATABASE",
                       "value": Config.oauth.dbname
                     },
                     {
                       "name": "MYSQL_LOG_CONSOLE",
                       "value": "true"
                     }
                   ]
                 }
               ],
               "volumes": [
                 {
                   "name": "vol",
                   "persistentVolumeClaim": {
                     "claimName": Config.nfsvol
                   }
                 }
               ]
             }
           }
         }
       },
      ],
  },
}
