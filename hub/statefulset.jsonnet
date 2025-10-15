local Config = import '../config.libsonnet';

{
  'statefulset.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
        {
          apiVersion: 'apps/v1',
          kind: 'StatefulSet',
          metadata: {
            name: Config.hub.appname,
            namespace: Config.ns,
          },
          spec: {
            serviceName: Config.hub.appname,
            podManagementPolicy: 'Parallel',
            replicas: 1,
            selector: {
              matchLabels: {
                app: Config.hub.appname,
              },
            },
            template: {
              metadata: {
                labels: {
                  app: Config.hub.appname,
                },
              },
              spec: {
                //                initContainers: [
                //                  {
                //                    name: 'init-gitclone',
                //                    image: 'ajeetraina/alpine-git',
                //                    command: [
                //                      'sh',
                //                      '-c',
                //                      'git clone -b kubernetes https://github.com/kooplex/kooplex-hub.git /x || true',
                //                    ],
                //                    volumeMounts: [
                //                      {
                //                        mountPath: '/x',
                //                        name: 'svc',
                //                        subPath: 'code',
                //                      },
                //                    ],
                //                  },
                //                ],
                containers: [
                  {
                    image: 'bitnami/redis:latest',
                    name: 'redis',
                    ports: [
                      {
                        containerPort: 6379,
                        name: 'redis',
                      },
                    ],
                    volumeMounts: [
                      {
                        mountPath: '/kooplexhub',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/redis',
                      },
                    ],
                    env: [
                      {
                        name: 'REDIS_PASSWORD',
                        value: Config.hub.redis_pw,
                      },
                    ],
                  },
                  {
                    image: 'nginx',
                    name: 'staticnginx',
                    ports: [
                      {
                        containerPort: 80,
                        name: 'http',
                      },
                    ],
                    resources: {
                      requests: {
                        cpu: '300m',
                        memory: '200Mi',
                      },
                      limits: {
                        cpu: '1',
                        memory: '4Gi',
                      },
                    },
                    volumeMounts: [
                      {
                        mountPath: '/usr/share/nginx/html/',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/code/static',
                      },
                    ],
                  },
                  {
                    image: Config.hub.image,
                    lifecycle: {
                      postStart: {
                        exec: {
                          command: [
                            '/bin/sh',
                            '-c',
                            Config.hub.command,
                          ],
                        },
                      },
                    },
                    name: Config.hub.appname,
                    ports: [
                      {
                        containerPort: 8080,
                        name: 'http',
                      },
                    ],
                    resources: {
                      requests: {
                        cpu: '1',
                        memory: '400Mi',
                      },
                      limits: {
                        cpu: '2',
                        memory: '4Gi',
                      },
                    },
                    volumeMounts: [
                      {
                        mountPath: '/root/.kube',
                        name: 'kubeconf',
                      },
                      {
                        mountPath: '/kooplexhub',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/code',
                      },
                      {
                        mountPath: '/var/log/hub',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/log',
                      },
                      {
                        mountPath: '/mnt/home',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/home',
                      },
                      {
                        mountPath: '/mnt/garbage',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/garbage',
                      },
                      {
                        mountPath: '/mnt/projects',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/projects',
                      },
                      {
                        mountPath: '/mnt/reports',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/report',
                      },
                      {
                        mountPath: '/mnt/report_prepare',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/report_prepare',
                      },
                      {
                        mountPath: '/mnt/courses',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/edu',
                      },
                      {
                        mountPath: '/etc/mnt',
                        name: 'nslcd',
                        readOnly: true,
                      },
                      {
                        mountPath: '/.init_scripts',
                        name: 'init',
                        readOnly: true,
                      },
                      {
                        mountPath: '/mnt/attachments',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/attachment',
                      },
                      {
                        mountPath: '/mnt/scratch',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '/scratch',
                      },
                    ],
                    env: [
                      {
                        name: 'HUBDBROOT_PW',
                        value: Config.hub.dbrootpw,
                      },
                      {
                        name: 'HUBDB_HOSTNAME',
                        value: 'hub-mysql',
                      },
                      {
                        name: 'LANG',
                        value: 'en_US.UTF-8',
                      },
                      {
                        name: 'DJANGO_SECRET_KEY',
                        value: Config.hub.djangosecret,
                      },
                      {
                        name: 'PREFIX',
                        value: Config.ns,
                      },
                      {
                        name: 'DOMAIN',
                        value: Config.fqdn,
                      },
                      {
                        name: 'HUBDB',
                        value: Config.hub.dbname,
                      },
                      {
                        name: 'HUBDB_USER',
                        value: Config.hub.dbuser,
                      },
                      {
                        name: 'HUBDB_PW',
                        value: Config.hub.dbpw,
                      },
                      {
                        name: 'HUBLDAP_PW',
                        value: Config.ldap.pw,
                      },
                      {
                        name: 'REDIS_PASSWORD',
                        value: Config.hub.redis_pw,
                      },
                      {
                        name: 'REDIS_TELEPORT',
                        value: Config.hub.redis_teleport,
                      },
                    ],
                  },
                ],
                //nodeSelector: {
                //  'kubernetes.io/hostname': Config.hub.nodename,
                //},
                volumes: [
                  {
                    name: 'kubeconf',
                    configMap: {
                      name: 'kubeconfig',
                      items: [
                        {
                          key: 'kubeconfig',
                          path: 'config',
                        },
                        //                        {
                        //                          key: 'kubejobsconfig',
                        //                          path: 'jobsconfig',
                        //                        },
                      ],
                    },
                  },
                  {
                    name: 'svc',
                    persistentVolumeClaim: {
                      claimName: Config.nfsvol,
                    },
                  },
                  //                  {
                  //                    name: 'home',
                  //                    persistentVolumeClaim: {
                  //                     claimName: Config.nfsvol
                  //                    },
                  //                  },
                  //                  {
                  //                    name: 'garbage',
                  //                    persistentVolumeClaim: {
                  //                     claimName: Config.nfsvol
                  //                    },
                  //                  },
                  //                  {
                  //                    name: 'edu',
                  //                    persistentVolumeClaim: {
                  //                     claimName: Config.nfsvol
                  //                    },
                  //                  },
                  //                  {
                  //                    name: 'scratch',
                  //                    persistentVolumeClaim: {
                  //                     claimName: Config.nfsvol
                  //                    },
                  //                  },
                  //                  {
                  //                    name: 'attachment',
                  //                    persistentVolumeClaim: {
                  //                     claimName: Config.nfsvol
                  //                    },
                  //                  },
                  //                  {
                  //                    name: 'project',
                  //                    persistentVolumeClaim: {
                  //                     claimName: Config.nfsvol
                  //                    },
                  //                  },
                  //                  {
                  //                    name: 'report',
                  //                    persistentVolumeClaim: {
                  //                     claimName: Config.nfsvol
                  //                    },
                  //                  },
                  {
                    name: 'nslcd',
                    configMap: {
                      name: 'nslcd',
                      items: [
                        {
                          key: 'nslcd',
                          path: 'nslcd.conf',
                        },
                      ],
                    },
                  },
                  {
                    name: 'init',
                    configMap: {
                      name: 'hubstartupscripts',
                      items: [
                        {
                          key: 'nsswitch',
                          path: '01-nsswitch.sh',
                        },
                        {
                          key: 'nslcd',
                          path: '02-nslcd.sh',
                        },
                        {
                          key: 'aliases',
                          path: '04-aliases.sh',
                        },
                        //                        {
                        //                          key: 'teleport',
                        //                          path: '05-teleport.sh',
                        //                        },
                        {
                          key: 'runqueue',
                          path: '98-runqueue.sh',
                        },
                        {
                          key: 'runserver',
                          path: '99-runserver.sh',
                        },
                      ],
                    },
                  },
                ],
              },
            },
          },
        },
        {
          apiVersion: 'apps/v1',
          kind: 'StatefulSet',
          metadata: {
            name: Config.hub.appname + '-mysql',
            namespace: Config.ns,
          },
          spec: {
            serviceName: Config.hub.appname + '-mysql',
            podManagementPolicy: 'Parallel',
            replicas: 1,
            selector: {
              matchLabels: {
                app: Config.hub.appname + '-mysql',
              },
            },
            template: {
              metadata: {
                labels: {
                  app: Config.hub.appname + '-mysql',
                },
              },
              spec: {
                containers: [
                  {
                    image: 'mariadb:11.2',
                    name: Config.hub.appname + '-mysql',
                    ports: [
                      {
                        containerPort: 3306,
                        name: 'mysql',
                      },
                    ],
                    volumeMounts: [
                      {
                        mountPath: '/var/lib/mysql',
                        name: 'svc',
                        subPath: Config.instance_subpath + Config.hub.appname + '-mysql/mysql',
                      },
                    ],
                    resources: {
                      requests: {
                        cpu: '200m',
                        memory: '400Mi',
                      },
                      limits: {
                        cpu: '2',
                        memory: '4Gi',
                      },
                    },
                    env: [
                      {
                        name: 'MYSQL_ROOT_PASSWORD',
                        value: Config.hub.dbrootpw,
                      },
                      {
                        name: 'MYSQL_USER',
                        value: Config.hub.dbuser,
                      },
                      {
                        name: 'MYSQL_PASSWORD',
                        value: Config.hub.dbpw,
                      },
                      {
                        name: 'MYSQL_DATABASE',
                        value: Config.hub.dbname,
                      },
                      {
                        name: 'MYSQL_LOG_CONSOLE',
                        value: 'true',
                      },
                    ],
                  },
                ],
                //nodeSelector: {
                //  'kubernetes.io/hostname': Config.hub.nodename,
                //},
                volumes: [
                  {
                    name: 'svc',
                    persistentVolumeClaim: {
                      claimName: Config.nfsvol,
                    },
                  },
                ],
              },
            },
          },
        },
      ],
  },
}
