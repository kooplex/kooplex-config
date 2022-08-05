local Config = import '../config.libsonnet';

{
  'configmaps.yaml-raw': {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'reports-siteconf',
      namespace: Config.ns,
    },
    data: {
      siteconf: 'server {\nlisten 80;\nserver_name k8plex-test.vo.elte.hu;\nclient_max_body_size 0M;\n\naccess_log /var/log/nginx/access.log;\nerror_log /var/log/nginx/error.log;\n#index  index.php index.html;\n\n####### Custom pages\n#   error_page 404 /custom_404.html;\n#   location = /custom_404.html {\n#        root /usr/share/nginx/html;\n#        internal;\n#   }\n#\n#   error_page 502 /custom_502.html;\n#   location = /custom_502.html {\n#        root /usr/share/nginx/html;\n#        internal;\n#   }\n####### Custom pages end\n\n       root /srv/reports/;\nlocation / {\n        #                  autoindex on;\n}\n\n#  location / {\n#    alias /srv/;\n#    index index.php;\n#    if ($request_uri !~ ^/(index\\.php/?|assets|files|robots\\.txt|css|images|themes|ci3_sessions|simplesaml)) {\n##    if ($request_uri !~ ^/(index\\.php/?|assets|files|robots\\.txt|css|images|themes|ci3_sessions)) {\n#      rewrite ^/(.*)$ /index.php/$1 last;\n#    }\n#  }\n\n\ninclude /etc/nginx/conf.d/sites-enabled/*;\n\n}\n',
    },
  },
}
