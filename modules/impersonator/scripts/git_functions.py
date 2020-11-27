#!/usr/bin/env python

import os
import subprocess
import logging
import pwd
import shutil

from common import sudo, list_processes_by_name
try:
    from urllib.parse import urlparse
except ImportError:
    from urlparse import urlparse

# initialization
logger = logging.getLogger(__name__)

def root_folder(username, service_url):
    D_PARENT = os.getenv('MNT_VOL_REPO', '/tmp')
    o = urlparse(service_url)
    return os.path.join(D_PARENT, username, o.netloc.replace('.', '_'))

def clone_folder(url_clone_repo):
    owner, project = os.path.split(urlparse(url_clone_repo).path)
    if owner[0] == '/':
        owner = owner[1:]
    if project.endswith('.git'):
        project = project[:-4]
    return '{}_{}'.format(project, owner)

###########################################
# git manipulation
###########################################

def start_agent(username):
    for p in list_processes_by_name('ssh-agent', username):
        logger.info('process {p[cmdline]} for user {p[username]} is already running ({p[status]}, pid={p[pid]})'.format(p = p))
        return 0
    cmd = [ 'ssh-agent', '-a', os.path.join('/tmp', username) ]
    logger.info('start ssh agent -- {}'.format(cmd))
    proc = subprocess.Popen(cmd, env = dict(os.environ))
    proc_ret = proc.wait()
    logger.info('process response: {}'.format(proc_ret))
    return proc_ret

def add_identity(username, rsa):
    env_dict = dict(os.environ)
    env_dict['SSH_AUTH_SOCK'] = '/tmp/{}'.format(username)
    cmd = [ 'ssh-add', rsa ]
    logger.info('adding rsa key {} -- {}'.format(rsa, cmd))
    proc = subprocess.Popen(cmd, env = env_dict)
    proc_ret = proc.wait()
    logger.info('rsa key added: {}'.format(proc_ret))
    return proc_ret

@sudo
def clone_repo(username, rsa, service_url, url_clone_repo):
    fn_rsa = '/tmp/.{}.rsa'.format(username)
    open(fn_rsa, 'w').write(rsa)
    os.chmod(fn_rsa, 0o600)
    env_dict = dict(os.environ)
    env_dict['SSH_AUTH_SOCK'] = '/tmp/{}'.format(username)
    start_agent(username)
    add_identity(username, fn_rsa)
    os.unlink(fn_rsa)
    cmd = [ 'git', 'clone', url_clone_repo, os.path.join(root_folder(username, service_url), clone_folder(url_clone_repo)) ]
    logger.info('cloning for {} -- {}'.format(username, cmd))
    proc = subprocess.Popen(cmd, env = env_dict)
    proc_ret = proc.wait()
    logger.info('process response: {}'.format(proc_ret))
    return proc_ret


def rmdir_repo(username, service_url, url_clone_repo):
    folder = os.path.join(root_folder(username, service_url), clone_folder(url_clone_repo))
    if os.path.exists(folder):
        shutil.rmtree(folder)
        logger.info('removed folder {}'.format(folder))
    return folder


def mkdir_repo(username, service_url):
    f = root_folder(username, service_url)
    U = pwd.getpwnam(username)
    if not os.path.exists(f):
        os.makedirs(f)
        os.chown(f, U.pw_uid, U.pw_gid)
        logger.info('Created {}'.format(f))
