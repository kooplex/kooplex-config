# Code Modification
seafile-server-latest/seahub/seahub/utils/__init__.py
def is_valid_username(username):
    """Check whether username is valid, currently only email can be a username.
    """
    return True#is_valid_email(username)

