#!/usr/bin/env python

import os
import subprocess
import logging
import pwd
import shutil

from common import sudo

# initialization
logger = logging.getLogger(__name__)

###########################################
# git manipulation
###########################################
class myGitCommand:
    D_PARENT = '/mnt/.volumes/git'

    def __init__(self, username, backend, server, port, reponame):
        self._u = username
        self.sock_file = '/tmp/.{}'.format(username)
        self.sock_env = '{}'.format(self.sock_file)
        repo = '{}-{}-{}-{}'.format(backend, server, username, reponame)
        self.repo_dir = os.path.join(self.D_PARENT, repo)
        self.url = 'ssh://git@{}:{}/{}/{}.git'.format(server, port, username, repo)



def start_agent(username):
    #FIXME: skip if running
    cmd = [ 'ssh-agent', '-a', os.path.join('/tmp', username) ]
    logger.info('start ssh agent -- {}'.format(cmd))
    proc = subprocess.Popen(cmd, env = dict(os.environ))
    proc_ret = proc.wait()
    logger.info('process response: {}'.format(proc_ret))
    return proc_ret

#FIXME: add identity

@sudo
def clone_repo(username, url_clone_repo, port, folder):
    folder = os.path.join(myGitCommand.D_PARENT, folder)
    start_agent(username)
    cmd = [ 'SSH_AUTH_SOCK=/tmp/{}'.format(username), 'git', 'clone', url_clone_repo, folder ] #FIXME: port
    logger.info('cloning for {} -- {}'.format(username, cmd))
    proc = subprocess.Popen(cmd, env = dict(os.environ))
    proc_ret = proc.wait()
    logger.info('process response: {}'.format(proc_ret))
    return proc_ret


def rmdir_repo(folder):
    if not os.path.exists(folder):
        return
    shutil.rmtree(folder)
    logger.info('removed folder {}'.format(folder))


def mkdir_repo(username, folder):
    folder = os.path.join(myGitCommand.D_PARENT, folder)
    if os.path.exists(folder):
        rmdir_repo(folder)
    os.mkdir(folder)
    u = pwd.getpwnam(username)
    os.chown(folder, u.pw_uid, u.pw_gid)
    logger.info('created folder {} for {} ({}:{})'.format(folder, username, u.pw_uid, u.pw_gid))
