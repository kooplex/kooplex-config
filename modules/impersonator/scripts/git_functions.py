#!/usr/bin/env python

import os
import subprocess
import logging
import pwd

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
        self.sock_env = 'SSH_AUTH_SOCK={}'.format(self.sock_file)
        repo = '{}-{}-{}-{}'.format(backend, server, username, reponame)
        self.repo_dir = os.path.join(self.D_PARENT, repo)
        self.url = 'ssh://git@{}:{}/{}/{}.git'.format(server, port, username, repo)

    def start_agent(self):
        cmd = [ 'ssh-agent', '-a', self.sock_file ]
        proc = subprocess.Popen(cmd, env = dict(os.environ))
        logger.info('cloning for {} -- {}'.format(self._u, cmd))
        proc_ret = proc.wait()
        logger.info('process response: {}'.format(proc_ret))
        return proc_ret

    def clone(self):
        cmd = [ self.sock_env, 'git', 'clone', self.url, self.repo_dir ]
        proc = subprocess.Popen(cmd, env = dict(os.environ))
        logger.info('cloning for {} -- {}'.format(self._u, cmd))
        proc_ret = proc.wait()
        logger.info('process response: {}'.format(proc_ret))
        return proc_ret


@sudo
def clone_repo(username, backend, server, port, reponame):
    c = myGitCommand(username, backend, server, port, reponame)
    m1 = c.start_agent
    m2 = c.clone()
    return m1, m2

def mkdir_repo(username, backend, server, reponame):
    c = myGitCommand(username, backend, server, 22, reponame)
    os.mkdir(c.repo_dir)
    u = pwd.getpwnam(username)
    os.chown(c.repo_dir, u.pw_uid, pw_gid)
