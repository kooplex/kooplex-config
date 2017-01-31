admin: tools for managing the software stack
base:  docker image with LDAP and NFS-client
binder: to delete
gitlab: gitlab with LDAP authentication
home: NFS-server
jupyterhub: to delete
ldap: openldap server
net: configures docker bridge network
nginx: world-facing nginx reverse-proxy
notebook: jupyter notebook base docker image
owncloud: to be replaced with nextcloud
proxy: configurable-http-proxy for notebooks





           build  install  start   init    check    stop   remove   purge   clean
             |       |       |       |       |       |       |       |       |

base         X       X                                               X       X
net                  X                                       X
             
ldap         X       X       X       X       X       X       X       X       X
nfs                  X       X                       X       X       X
home                 X       X                       X       X       X
mysql        X       X       X               X       X       X       X       X
nginx
admin
gitlab
owncloud
notebook
proxy
hub

dashboard














