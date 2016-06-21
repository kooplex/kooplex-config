import datetime as dt
import subprocess

class RepoUtils:
  """
  This class is a helper class for repository management.
  
  It contains functions which are useful for this purpose:
      - check out an existing repository
      - purge a cloned repository
  """

  def __init__(self, args):
    config_file = args.config_file
    project_name = args.project_name

  def checkout_repo(self, source_username, target_username, reponame):
    """
    This function checks out an existing repository
    """
    gitlab_url = "http://" + self.project_name + "-gitlab/gitlab/"
    gitlab_url += source_username + "/"
    gitlab_url += reponame + ".git"
    target_path = "/home/" + target_username + "/" + reponame
    subprocess.call(["git", "clone", gitlab_url, target_path])

  def purge_repo(self, target_username, reponame):
    """
    This function purges a cloned repository
    """
    target_path = "/home/" + target_username + "/" + reponame
    subprocess.call(["rm", "-r", target_path])
