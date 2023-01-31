local Config = import 'config.libsonnet';

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
            name: 'tcp-services',
            //namespace: Config.ns,
            namespace: 'ingress-nginx',
          },
          data: {
            '30576': 'gitea/gitea-ssh:30576',
          },
        },

      ],
  },
}
