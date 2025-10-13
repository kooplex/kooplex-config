local Config = import '../config.libsonnet';

{
  'statefulset_provider.yaml-raw': {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: Config.ldap.appname,
      namespace: Config.ns,
    },
    spec: {
      serviceName: Config.ldap.appname + '-test',
      podManagementPolicy: 'Parallel',
      replicas: 1,
      selector: {
        matchLabels: {
          app: Config.ldap.appname,
        },
      },
      template: {
        metadata: {
          labels: {
            app: Config.ldap.appname,
          },
        },
        spec: {
          containers: [
            {
              image: 'osixia/openldap:1.5.0',
              name: Config.ldap.appname,
              command: [
                '/container/tool/run',
                '--dont-touch-etc-hosts',
              ],
              ports: [
                {
                  containerPort: 389,
                  name: 'ldap',
                },
              ],
              resources: {
                requests: {
                  cpu: '200m',
                  memory: '200Mi',
                },
                limits: {
                  cpu: '1',
                  memory: '1Gi',
                },
              },
              volumeMounts: [
                {
                  mountPath: '/var/log/ldap',
                  name: 'svc',
                  subPath: 'log',
                },
                {
                  mountPath: '/var/lib/ldap',
                  name: 'svc',
                  subPath: 'db',
                },
                {
                  mountPath: '/usr/local/ldap',
                  name: 'svc',
                  subPath: 'helper',
                },
                {
                  mountPath: '/etc/ldap/slapd.d',
                  name: 'svc',
                  subPath: 'slapd.d',
                },
              ],
              env: [
                {
                  name: 'LDAP_ORGANISATION',
                  value: 'kooplex organization',
                },
                {
                  name: 'LDAP_DOMAIN',
                  value: Config.fqdn,
                },
                {
                  name: 'LDAP_ADMIN_PASSWORD',
                  value: Config.ldap.pw,
                },
              ],
            },
          ],
          volumes: [
            {
              name: 'svc',
              persistentVolumeClaim: {
                claimName: 'ldap-data',
              },
            },
          ],
        },
      },
    },
  },
}
