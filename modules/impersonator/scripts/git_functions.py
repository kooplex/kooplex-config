#!/usr/bin/env python

import os
import subprocess
import logging
import pwd
import shutil

from common import sudo, list_processes_by_name

# initialization
logger = logging.getLogger(__name__)

###########################################
# git manipulation
###########################################
def expand_folder(folder):
    return os.path.join('/mnt/.volumes/git', folder)

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
def clone_repo(username, rsa, url_clone_repo, port, folder):
    assert os.path.exists(rsa), "RSA file {} does not exist".format(rsa)
    env_dict = dict(os.environ)
    env_dict['SSH_AUTH_SOCK'] = '/tmp/{}'.format(username)
    start_agent(username)
    add_identity(username, rsa)
    cmd = [ 'git', 'clone', url_clone_repo, expand_folder(folder) ] #FIXME: port
    logger.info('cloning for {} -- {}'.format(username, cmd))
    proc = subprocess.Popen(cmd, env = env_dict)
    proc_ret = proc.wait()
    logger.info('process response: {}'.format(proc_ret))
    return proc_ret


def rmdir_repo(folder):
    folder_abs = expand_folder(folder)
    if not os.path.exists(folder_abs):
        return
    shutil.rmtree(folder_abs)
    logger.info('removed folder {}'.format(folder))


def mkdir_repo(username, folder):
    folder_abs = expand_folder(folder)
    if os.path.exists(folder_abs):
        rmdir_repo(folder)
    os.mkdir(folder_abs)
    u = pwd.getpwnam(username)
    os.chown(folder_abs, u.pw_uid, u.pw_gid)
    logger.info('created folder {} for {} ({}:{})'.format(folder, username, u.pw_uid, u.pw_gid))
