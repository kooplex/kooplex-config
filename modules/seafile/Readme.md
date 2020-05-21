# First make sure that seafile accesse to the databases are working
# I had to replace seafile user to root in order to work in 
# conf/seafile.conf
# conf/ccnet.conf
# conf/seahub_settings.py

# Code Modification
# seafile-server-latest/seahub/seahub/utils/__init__.py
Line 290
def is_valid_username(username):
    """Check whether username is valid, currently only email can be a username.
    """
    return True#is_valid_email(username)

# TODO sed instead of patch
# Ekkor valamiert a conatc_email is az idp_user lesz
#/opt/seafile/seafile-server-latest/seahub/seahub/oauth/views.py 

Line 143
  user_info['idp_user'] = user_info_json['idp_user']
Line 168
  email = user_info['idp_user']


Line 118
  authorization_response="https://kooplex-test.elte.hu/"+request.get_full_path())

Line 195 ?213
# Before name and contact_email is validated
    if isinstance(name, list):
        name = name.pop(0)
    if isinstance(contact_email, list):
        contact_email = contact_email.pop(0)


* We have copy the settings.py and ccnet.conf from /shared
* Hydra secret is not yet automatized: after install-hydra, you have to copy the secret manually
