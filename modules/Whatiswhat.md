Core modules
 * hub: the main portal  
 * impersonator: background services that need root privileges
 * manual: manual
 * base:  docker image with LDAP and NFS-client
 * binder: to delete
 * home: NFS-server
 * jupyterhub: to delete
 * ldap: openldap server
 * net: configures docker bridge network
 * notebook: jupyter notebook base docker image
 * proxy: configurable-http-proxy for notebooks
 * prometheus, cadvisor, node_exporter, grafana 
 * hydra: central authenticating system
 * outerhost_nginx:  world-facing nginx reverse-proxy to route to components, this or the above is not needed
 * report-nginx: nginx-webserver to route to reports
 * singularityhub: for singularity, for user environment customization
 * admin (not used): tools for managing the software stack
 * slurm: Workload manager

Version control systems:
 * gitea:
 * gitlab: gitlab with LDAP authentication

Cloud based file sharing systems
 * seafile:     
 * owncloud: to be replaced with nextcloud


overleaf (not used): Lacks the feature to use openid, for editing papers
dashboard (not used):
dockssh (not used): direct terminal in a container
syscheck (not used): for checking system components
userdb (not used): to run databases for users in containers
nginx (deprecated): world-facing nginx reverse-proxy
