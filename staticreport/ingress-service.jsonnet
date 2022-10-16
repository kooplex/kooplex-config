local Config = import '../config.libsonnet';

{
  'ingress_static.yaml-raw': {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'staticreport',
      namespace: Config.ns,
      annotations: {
        'nginx.ingress.kubernetes.io/enable-cors': 'true',
        'kubernetes.io/ingress.class': 'nginx',
        'nginx.ingress.kubernetes.io/rewrite-target': '/$2',
        'nginx.ingress.kubernetes.io/proxy-body-size': '0M',
      },
    },
    spec: {
      tls: [
        {
          hosts: [
            Config.fqdn,
          ],
          secretName: Config.ns + '-tls',
        },
      ],
      rules: [
        {
          host: Config.fqdn,
          http: {
            paths: [
              {
                path: '/report(/|$)(.*)',
                pathType: 'Prefix',
                backend: {
                  service: {
                    name: 'staticreport',
                    port: {
                      number: 80,
                    },
                  },
                },
              },
            ],
          },
        },
      ],
    },
  },
  'ingress_shiny.yaml-raw': {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'shinyreport',
      namespace: Config.ns,
      annotations: {
        'nginx.ingress.kubernetes.io/rewrite-target': '/$2',
        'nginx.ingress.kubernetes.io/enable-cors': 'true',
        'kubernetes.io/ingress.class': 'nginx',
        'nginx.ingress.kubernetes.io/proxy-body-size': '0M',
        //  location /shiny {
        //      rewrite ^/shiny/(.*)$ /$1 break;
        //        proxy_pass       http://##PREFIX##-shiny:3838;
        //      proxy_redirect / $scheme://$http_host/shiny/;
        //
        //        proxy_http_version    1.1;
        //        proxy_set_header      Upgrade $http_upgrade;
        //        proxy_set_header      Connection "upgrade";
        //        proxy_set_header X-Real-IP $remote_addr;
        //        proxy_set_header Connection keep-alive;
        //        proxy_set_header Host $host;
        //        proxy_cache_bypass $http_upgrade;
        //        proxy_read_timeout 20d;
        //        proxy_buffering off;
        //  }

      },
    },
    spec: {
      tls: [
        {
          hosts: [
            Config.fqdn,
          ],
          secretName: Config.ns + '-tls',
        },
      ],
      rules: [
        {
          host: Config.fqdn,
          http: {
            paths: [
              {
                path: '/shiny(/|$)(.*)',
                pathType: 'Prefix',
                backend: {
                  service: {
                    name: 'shinyreport',
                    port: {
                      number: 3838,
                    },
                  },
                },
              },
            ],
          },
        },
      ],
    },
  },
  'ingress_dynamic_report.yaml-raw': {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'proxy-dynamic-report',
      namespace: Config.ns,
      annotations: {
        'kubernetes.io/ingress.class': 'nginx',
        'nginx.org/websocket-services': 'proxy',
        'nginx.ingress.kubernetes.io/proxy-body-size': '0',
        'nginx.ingress.kubernetes.io/proxy-buffer-size': '16k',
        'nginx.ingress.kubernetes.io/client-header-buffers': '100k',
        'nginx.ingress.kubernetes.io/large-client-header-buffers': '4 1000k',
        'nginx.ingress.kubernetes.io/client-body-buffer-size': '10M',
        'nginx.ingress.kubernetes.io/proxy-add-original-uri-header': 'false',
      },
    },
    spec: {
      tls: [
        {
          hosts: [
            Config.fqdn,
          ],
          secretName: Config.ns + '-tls',
        },
      ],
      rules: [
        {
          host: Config.fqdn,
          http: {
            paths: [
              {
                path: '/dreport',
                pathType: 'Prefix',
                backend: {
                  service: {
                    name: 'proxy',
                    port: {
                      number: 8000,
                    },
                  },
                },
              },
            ],
          },
        },
      ],
    },
  },
}
