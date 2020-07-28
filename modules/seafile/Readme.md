# First make sure that seafile accesse to the databases are working
# I had to replace seafile user to root in order to work in 
# conf/seafile.conf
# conf/ccnet.conf
# conf/seahub_settings.py

1.
# Code Modification
# seafile-server-latest/seahub/seahub/utils/__init__.py
Line 290
def is_valid_username(username):
    """Check whether username is valid, currently only email can be a username.
    """
    return True#is_valid_email(username)

sed -i '290c\    return True#' seafile-server-latest/seahub/seahub/utils/__init__.py


# TODO sed instead of patch
# Ekkor valamiert a conatc_email is az idp_user lesz
# /opt/seafile/seafile-server-latest/seahub/seahub/oauth/views.py 

Line 143
sed -i "143c\        user_info['idp_user'] = user_info_json['idp_user']" /opt/seafile/seafile-server-latest/seahub/seahub/oauth/views.py
Line 168
sed -i '167c\    email = user_info['idp_user']' /opt/seafile/seafile-server-latest/seahub/seahub/oauth/views.py

Line 195 ?213
# Before name and contact_email is validated
sed -i '192a\    if isinstance(name, list):\n        name = name.pop(0)' /opt/seafile/seafile-server-latest/seahub/seahub/oauth/views.py
sed -i '198a\    if isinstance(contact_email, list):\n       contact_email = contact_email.pop(0)' /opt/seafile/seafile-server-latest/seahub/seahub/oauth/views.py


2. Hydra secret is not yet automatized: after install-hydra, you have to copy the secret manually
OAUTH_CLIENT_ID
OAUTH_CLIENT_SECRET
