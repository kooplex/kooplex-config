#!/bin/bash

PROJECTDB=$PROJECT"_kooplex"

case $VERB in
  "build")
    echo "Building base image kooplex-hub"

    LDAPPASS=$(getsecret ldap)
    GITLABPASS=$(getsecret gitlab)
    SSHKEYPASS=$(getsecret sshkey)

cat << EOO > Runserver.sh

cd /kooplexhub/kooplexhub/
git pull
/usr/bin/python3 manage.py runserver $HUBIP:80

EOO



cat << EOD > docker-entrypoint.sh
#!/bin/bash
set -e

if [ ! -e 'kooplexhub/kooplexhub/kooplex/settings.py' ]; then
        cp /settings.py kooplexhub/kooplexhub/kooplex/settings.py

fi

v=\`echo "use $PROJECTDB; show tables" | mysql -u root --password=$MYSQLPASS -h $PROJECT-mysql | wc| awk '{print \$1}'\`
if [ !  "\$v" -gt "10" ]; then
        cd /kooplexhub/kooplexhub/; python3 manage.py migrate; cd /
fi

exec "\$@"
EOD



cat << EOF > settings.py

"""
Django settings for kooplex project.
"""

from os import path

PROJECT_ROOT = path.dirname(path.abspath(path.dirname(__file__)))

DEBUG = True

ALLOWED_HOSTS = (
    'localhost',
)

ADMINS = (
    # ('Your Name', 'your_email@example.com'),
)

MANAGERS = ADMINS

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': '$PROJECTDB',
        'USER': 'kooplex',
        'PASSWORD': '$MYSQLPASS',
        'HOST': '$MYSQLIP',
        'PORT': '3306',
    }
}

# LDAP authentication backend
#AUTHENTICATION_BACKENDS = (
#    'django_auth_ldap.backend.LDAPBackend',
#)

#AUTH_LDAP_SERVER_URI = "ldap://retdb02:32771"
#AUTH_LDAP_USER_SEARCH = LDAPSearch("ou=users,dc=compare,dc=vo,dc=elte,dc=hu",
#                                   ldap.SCOPE_SUBTREE, "(uid=%(user)s)")

#AUTH_LDAP_USER_ATTR_MAP = {
#    "first_name": "givenName",
#    "last_name": "sn",
#}


#SOCIALACCOUNT_PROVIDERS = {
#    'gitlab': {
#        'GITLAB_URL': 'http://compare.vo.elte.hu/gitlab/',
#        'GITLAB_KEY': '68bffc1d84eacc940851d152d7cb8f6a84bad5c3404fc8021f70b11ff316a75e',
#        'GITLAB_SECRET': '1e0d23aedb02408a5052e93ab17645ab3426f4f4258f928080164029e9cac21d'
#    }
#}


KOOPLEX_OUTER_HOST = '$OUTERHOST'
KOOPLEX_INTERNAL_HOST = '$INNERHOST'
KOOPLEX_INTERNAL_HOSTNAME = '$INNERHOSTNAME'
KOOPLEX_OUTER_PORT = '$OUTERHOSTPORT'

PROTOCOL = "$REWRITEPROTO"
KOOPLEX_BASE_URL = PROTOCOL + '://' + KOOPLEX_OUTER_HOST
KOOPLEX_HUB_PREFIX = 'hub'

KOOPLEX = {
    'debug': {
        'debug': $HUB_DEBUG,
    },
    'prefix':{
        'name': '$PREFIX',
    },
    'hub': {
        'internal_host' : KOOPLEX_INTERNAL_HOST,
        'outer_host' : KOOPLEX_OUTER_HOST,
        'host_port' : KOOPLEX_OUTER_PORT,
        'protocol' : PROTOCOL,
    },
    'users': {
        'srv_dir': '$SRV',
        'home_dir': 'home/{\$username}',
        'project_dir': 'projects/{\$path_with_namespace}',
    },
    'session': {
    	'base_url': 'http://%s' %(KOOPLEX_INTERNAL_HOST),
    },
    'ldap': {
        'host': '$LDAPSERV',
        'port': 389,
        'base_dn': '$LDAPORG',
        'bind_username': 'admin',
        'bind_password': '$LDAPPASS',
    },
    'gitlab': {
        'base_url': 'http://%s/gitlab/' % KOOPLEX_INTERNAL_HOST,
        'base_repourl': 'http://$GITLABIP',
        'ssh_cmd': r'/usr/bin/ssh',   # TODO def find_ssh()
        'ssh_host': '$PROJECT-gitlab',
        'ssh_port': 22,
        'admin_username': 'gitlabadmin',
        'admin_password': '$GITLABPASS',
        'ssh_key_password': '$SSHKEYPASS',
    },
    'docker': {
        'host': '$DOCKERIP', 
        'port': '$DOCKERPORT',
        'network': '$PROJECT-net',
        'protocol':'$DOCKERPROTOCOL',
    },
    'spawner': {
        'notebook_container_name': '$PROJECT-notebook-{\$username}-{\$project_name}',
        'notebook_ip_pool': ['$IPPOOLB', '$IPPOOLE'],
        'notebook_proxy_path': '/notebook/{\$username}/{\$notebook.id}',
        'srv_path': '$SRV'
    },
    'proxy': {
        'host': KOOPLEX_INTERNAL_HOST,        
        'port': 8001,   # api port
        'auth_token': '$PROXYTOKEN',
        'external_url': '%s/' % KOOPLEX_BASE_URL,
    },
    'owncloud': {
        'base_url': '%s/owncloud/' % KOOPLEX_BASE_URL,
    },
    'dashboards': {
        'dir': '{\$image_postfix}',
        'prefix': 'dashboards',
        'url_prefix': '/db/{\$dashboard_port}',
        'base_url': '%s/' % KOOPLEX_BASE_URL,
    }
}

# AllAuth authentication backend
TEMPLATES =  [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
         #'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.contrib.auth.context_processors.auth',

                # 'allauth' needs this from django
                # 'django.template.context_processors.request',

                'kooplex.lib.extra_context.extra_context',
                
            ],
            'debug': DEBUG,
            'loaders': [
                'django.template.loaders.filesystem.Loader',
                'django.template.loaders.app_directories.Loader',
                #     'django.template.loaders.eggs.Loader',
            ]
        },
    },
]

AUTHENTICATION_BACKENDS = (
    # Needed to login by username in Django admin, regardless of 'allauth'
    'django.contrib.auth.backends.ModelBackend',
    # 'allauth' specific authentication methods, such as login by e-mail
    #'allauth.account.auth_backends.AuthenticationBackend',
    'kooplex.lib.auth.Auth',
)

# LOGIN_URL = '/accounts/login'

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# On Unix systems, a value of None will cause Django to use the same
# timezone as the operating system.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'Europe/Berlin'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale.
USE_L10N = True

# If you set this to False, Django will not use timezone-aware datetimes.
USE_TZ = True

# Absolute filesystem path to the directory that will hold user-uploaded files.
# Example: "/home/media/media.lawrence.com/media/"
MEDIA_ROOT = ''

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash.
# Examples: "http://media.lawrence.com/media/", "http://example.com/media/"
MEDIA_URL = ''

# Absolute path to the directory static files should be collected to.
# Don't put anything in this directory yourself; store your static files
# in apps' "static/" subdirectories and in STATICFILES_DIRS.
# Example: "/home/media/media.lawrence.com/static/"
STATIC_ROOT = path.join(PROJECT_ROOT, 'static').replace('\\\\', '/')

# URL prefix for static files.
# Example: "http://media.lawrence.com/static/"
STATIC_URL = '/static/'

# Additional locations of static files
STATICFILES_DIRS = (
    # Put strings here, like "/home/html/static" or "C:/www/django/static".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
)

# List of finder classes that know how to find static files in
# various locations.
STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
#    'django.contrib.staticfiles.finders.DefaultStorageFinder',
)

# Make this unique, and don't share it with anybody.
SECRET_KEY = 'n(bd1f1c%e8=_xad02x5qtfn%wgwpi492e\$8_erx+d)!tpeoim'

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'threadlocals.middleware.ThreadLocalMiddleware',

    # Uncomment the next line for simple clickjacking protection:
    # 'django.middleware.clickjacking.XFrameOptionsMiddleware',

    # For oaut2 provider
    #'corsheaders.middleware.CorsMiddleware', 
)

SESSION_ENGINE = 'django.contrib.sessions.backends.signed_cookies'
CORS_ORIGIN_ALLOW_ALL = True

ROOT_URLCONF = 'kooplex.urls'

# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = 'kooplex.wsgi.application'

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Uncomment the next line to enable the admin:
    'django.contrib.admin',
    # Uncomment the next line to enable admin documentation:
    'django.contrib.admindocs',

    # AllAuth
    #'allauth',
    #'allauth.account',
    #'allauth.socialaccount',
    #'allauth.socialaccount.providers.gitlab',

    # OAuth2 provider
    #'corsheaders',
    #'oauth2_provider',

    'kooplex.hub.apps.HubConfig',
    'kooplex.hub.templatetags',

)

# Required by oauth2 provider
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'oauth2_provider.ext.rest_framework.OAuth2Authentication',
    )
}

# A sample logging configuration. The only tangible logging
# performed by this configuration is to send an email to
# the site admins on every HTTP 500 error when DEBUG=False.
# See http://docs.djangoproject.com/en/dev/topics/logging for
# more details on how to customize your logging configuration.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        }
    },
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler'
        }
    },
    'loggers': {
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}

# Specify the default test runner.
TEST_RUNNER = 'django.test.runner.DiscoverRunner'


EOF
	 
    mkdir -p $SRV/hub
    cp settings.py $SRV/hub/
    DATE=$(date +%y-%m-%d)
    docker $DOCKERARGS build -t kooplex-hub --build-arg CACHE_DATE=$DATE .

  ;;
  "install")
    echo "Installing hub $PROJECT-hub [$HUBIP]"

  cont_exist=`docker $DOCKERARGS ps -a | grep $PROJECT-hub | awk '{print $2}'`
    if [ ! $cont_exist ]; then
      if [ $DOCKERPROTOCOL == "unix" ]; then
        docker $DOCKERARGS create  \
          --name $PROJECT-hub \
          --hostname $PROJECT-hub \
          --net $PROJECT-net \
          --ip $HUBIP \
          --privileged \
          --log-opt max-size=1m --log-opt max-file=3 \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v $SRV/hub/settings.py:/kooplexhub/kooplexhub/kooplex/settings.py:ro \
          -v $SRV/home:$SRV/home \
          -v $SRV/dashboards:$SRV/dashboards \
          -v $SRV/notebook:$SRV/notebook \
            kooplex-hub
      else
        docker $DOCKERARGS create  \
          --name $PROJECT-hub \
          --hostname $PROJECT-hub \
          --net $PROJECT-net \
          --ip $HUBIP \
          --privileged \
          --log-opt max-size=1m --log-opt max-file=3 \
          -v $SRV/hub/settings.py:/kooplexhub/kooplexhub/kooplex/settings.py:ro \
          -v $SRV/home:$SRV/home \
          -v $SRV/dashboards:$SRV/dashboards \
          -v $SRV/notebook:$SRV/notebook \
            kooplex-hub
      fi
    else
     echo "$PROJECT-hub is already installed"
    fi

  ;;
  "start")
    echo "Starting hub $PROJECT-hub [$HUBIP]"

   if ! docker $DOCKERARGS exec $PROJECT-mysql bash -c "echo \"show databases\" | mysql -u root --password=$MYSQLPASS " | grep -q  $PROJECTDB ; then
   echo "CREATING mysql DATABASE for hub"
   docker $DOCKERARGS exec $PROJECT-mysql \
    bash -c "echo \"CREATE DATABASE \"$PROJECT\"_kooplex;\" | mysql -u root --password=$MYSQLPASS"
   docker $DOCKERARGS exec $PROJECT-mysql \
    bash -c "echo  \"   CREATE USER 'kooplex'@'%' IDENTIFIED BY '$MYSQLPASS';\" | mysql -u root --password=$MYSQLPASS"
   docker $DOCKERARGS exec $PROJECT-mysql \
    bash -c "echo \"    GRANT ALL ON \"$PROJECT\"_kooplex.* TO 'kooplex'@'%';\" | mysql -u root --password=$MYSQLPASS"
    
 else
  echo "mysql Database exists"
 fi

 docker $DOCKERARGS start $PROJECT-hub
    
  ;;
  "init")
    echo "Initializing $PROJECT-hub [$HUBIP]"
    docker $DOCKERARGS exec $PROJECT-hub bash -c "mkdir -p ~/.ssh; ssh-keyscan -H $PROJECT-gitlab >> ~/.ssh/known_hosts"
  ;;
  "refresh")
    echo "Pulling into hub"
     docker $DOCKERARGS exec $PROJECT-hub bash -c "cd /kooplexhub; git pull;"
  ;;
 "stop")
    echo "Stopping hub $PROJECT-hub [$HUBIP]"
    docker $DOCKERARGS stop $PROJECT-hub
  ;;
  "remove")
    echo "Removing hub $PROJECT-hub [$HUBIP]"
    docker $DOCKERARGS rm $PROJECT-hub

  ;;
  "purge")

  ;;
  "clean")
    echo "Cleaning base image kooplex-hub"
    docker $DOCKERARGS rmi kooplex-hub
  ;;
esac

