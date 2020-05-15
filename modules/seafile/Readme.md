# Code Modification
seafile-server-latest/seahub/seahub/utils/__init__.py
def is_valid_username(username):
    """Check whether username is valid, currently only email can be a username.
    """
    return True#is_valid_email(username)

# TODO sed instead of patch
 Ekkor valamiert a conatc_email is az idp_user lesz
in /opt/seafile/seafile-server-latest/seahub/seahub/oauth/views.py 
 143        user_info['idp_user'] = user_info_json['idp_user']
 168 email = user_info['idp_user']

* We have copy the settings.py and ccnet.conf from /shared
* Hydra secret is not yet automatized: after install-hydra, you have to copy the secret manually
