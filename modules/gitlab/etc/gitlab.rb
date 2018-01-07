external_url '##REWRITEPROTO##://##OUTERHOST##/gitlab'

gitlab_rails['gitlab_email_from'] = '##EMAIL##'
gitlab_rails['gitlab_email_display_name'] = '##PREFIX## gitlab'
gitlab_rails['gitlab_email_reply_to'] = '##EMAIL##'
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = '##SMTP##'
gitlab_rails['smtp_port'] = 25
#gitlab_rails['smtp_authentication'] = "plain"
#gitlab_rails['smtp_domain'] = "elte.hu"

nginx['listen_port'] = 80
nginx['http2_enabled'] = false
nginx['listen_https'] = false


gitlab_rails['gitlab_signup_enabled'] = false
gitlab_rails['gitlab_signin_enabled'] = false

gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # remember to close this block with 'EOS' below
  main:
    label: 'LDAP'
    host: '##PREFIX##-ldap'
    port: 389
    uid: 'uid'
    method: 'plain'
    bind_dn: 'cn=admin,##LDAPORG##'
    password: '##LDAPPW##'
    active_directory: false
    allow_username_or_email_login: false
    block_auto_created_users: false
    base: 'ou=users,##LDAPORG##'
    user_filter: '(objectClass=posixAccount)'
    attributes:
      username: ['uid', 'userid', 'sAMAccountName']
      email:    ['mail', 'email', 'userPrincipalName']
      name:       'cn'
      first_name: 'givenName'
      last_name:  'sn'
EOS

logging['logrotate_frequency'] = "daily" # rotate logs daily
logging['logrotate_size'] = nil # do not rotate by size by default
logging['logrotate_rotate'] = 30 # keep 30 rotated logs
logging['logrotate_compress'] = "compress" # see 'man logrotate'
logging['logrotate_method'] = "copytruncate" # see 'man logrotate'
logging['logrotate_postrotate'] = nil # no postrotate command by default
logging['logrotate_dateformat'] = nil # use date extensions for rotated files rather than numbers 
logging['log_level'] = 'ERROR'
mattermost['log_console_level'] = 'ERROR' 
mattermost['log_file_level'] = 'ERROR'
registry['log_level'] = 'error'
gitlab_shell['log_level'] = 'ERROR'

# Disable the built-in Postgres
postgresql['enable'] = false

# Fill in the values for database.yml
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = '##GITLABDB##'
gitlab_rails['db_port'] = '5432'
gitlab_rails['db_username'] = 'postgres'
gitlab_rails['db_password'] = '##GITLABDBPW##'

