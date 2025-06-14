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
              volumeMounts: [
                {
                  mountPath: '/var/log/ldap',
                  name: 'svc',
                  subPath: Config.instance_subpath+Config.ldap.appname+'/log',
                },
                {
                  mountPath: '/var/lib/ldap',
                  name: 'svc',
                  subPath: Config.instance_subpath+Config.ldap.appname+'/db',
                },
                {
                  mountPath: '/usr/local/ldap',
                  name: 'svc',
                  subPath: Config.instance_subpath+Config.ldap.appname+'/helper',
                },
                {
                  mountPath: '/etc/ldap/slapd.d',
                  name: 'svc',
                  subPath: Config.instance_subpath+Config.ldap.appname+'/slapd.d',
                },
              ],
              env: [
                {
                  name: 'LDAP_ORGANISATION',
                  value: 'kooplex organization',
                },
                {
                  name: 'LDAP_DOMAIN',
                  value: "kooplex",
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
                claimName: Config.nfsvol,
              },
            },
          ],
        },
      },
    },
  },
}
