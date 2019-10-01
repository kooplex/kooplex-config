#!/usr/bin/env python

import os
import pwd
import threading
import Queue as queue
import subprocess
from flask import Flask, jsonify
from flask_httpauth import HTTPBasicAuth
import random
import time
import logging

import urllib
import urllib2
from urlparse import urlparse
import json

import seafile

# initialization
logger = logging.getLogger(__name__)
app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'

# extensions
auth = HTTPBasicAuth()

@auth.verify_password
def verify_password(username, password):
    # Note: token base example at https://blog.miguelgrinberg.com/post/restful-authentication-with-flask
    return True if (username == 'hub') and (password == 'blabla') else False

###########################################

@app.route('/')
def get_alive():
    return jsonify({'message': 'API server is running'})

###########################################

def lookupuid(username):
    return pwd.getpwnam(username).pw_uid

def sudo(username, function, *args, **kwargs):
    uid = lookupuid(username)
    logger.info(username, uid, function, args, kwargs)
    q = queue.Queue()
    def worker():
        logger.debug('thread started, changing uid {}'.format(uid))
        os.setgid(1000)
        os.setuid(uid)
        try:
            result = function(*args, **kwargs)
            q.put_nowait((0, result))
            logger.debug('executed {}'.format(funtion))
        except Exception as e:
            logger.warn('executed {} -- exception {}'.format(function, e))
            q.put_nowait((1, e))
        logger.debug("thread ended")
    t = threading.Thread(target = worker)
    t.start()
    t.join()
    status, result = q.get_nowait()
    if status != 0:
        raise result
    return result

def randstring(size):
    random.seed(time.time())
    s = ''
    while len(s) < size:
        s += '%x' % random.randint(0, 255)
    return s[:size]


###########################################
# seafile daemon manipulation
###########################################
class FS:
    def __init__(self, username): self._u = username
    @property
    def seaf_conf_dir(self): return os.path.join('/home', self._u, '.seafconf') #FIXME: validate
    @property
    def seaf_log_dir(self): return os.path.join('/home', self._u, '.seafconf/logs')
    @property
    def seaf_path(self): return os.path.join('/mnt/.volumes/seafile', self._u)
    @property
    def seaf_data_dir(self): return os.path.join('/mnt/.volumes/seafile', self._u, 'seafile-data')
    @property
    def seaf_ini(self): return os.path.join('/home', self._u, '.seafconf/seafile.ini')
    @property
    def seaf_sock(self): return os.path.join('/mnt/.volumes/seafile', self._u, 'seafile-data/seafile.sock')

def seaf_init(username):
    fs = FS(username)
    assert not os.path.exists(fs.seaf_conf_dir), "Conf dir is existing %s" % fs.seaf_conf_dir
    os.mkdir(fs.seaf_conf_dir)
    os.mkdir(fs.seaf_log_dir)
    if not os.path.exists(fs.seaf_path):
        os.mkdir(fs.seaf_path)
    with open(fs.seaf_ini, 'w') as fp:
        fp.write(fs.seaf_data_dir)
    if not os.path.exists(fs.seaf_data_dir):
        os.mkdir(fs.seaf_data_dir)
    return "Created %s and folder %s is present" % (fs.seaf_ini, fs.seaf_path)

@app.route('/api/sync/init/<username>')
@auth.login_required
def get_sync_init(username):
    try:
        result = sudo(username, seaf_init, username)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(result) })


def seaf_status(username):
    fs = FS(username)
    seafile_rpc = seafile.RpcClient(fs.seaf_sock)
    return seafile_rpc.get_clone_tasks()

@app.route('/api/sync/info/<username>')
@auth.login_required
def get_sync_info(username):
    try:
        result = sudo(username, seaf_status, username)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(result) })


def seaf_start(username):
    fs = FS(username)
    cmd = [ "seaf-daemon", "--daemon", "-c", fs.seaf_conf_dir, "-d", fs.seaf_data_dir, "-w", fs.seaf_path ]
    proc = subprocess.Popen(cmd, env = dict(os.environ))
    return proc.wait()

@app.route('/api/sync/start/<username>')
@auth.login_required
def get_sync_start(username):
    try:
        result = sudo(username, seaf_start, username)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(result) })


def seaf_stop(username):
    fs = FS(username)
    seafile_rpc = seafile.RpcClient(fs.seaf_sock)
    seafile_rpc.shutdown()
    return "OK"

@app.route('/api/sync/stop/<username>')
@auth.login_required
def get_sync_stop(username):
    try:
        result = sudo(username, seaf_stop, username)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(result) })


device_id = None
def get_device_id(fs):
    global device_id
    if device_id:
        return device_id

    idfile = os.path.join(fs.seaf_data_dir, 'id')
    ccnet_conf = os.path.join(fs.seaf_conf_dir, 'ccnet.conf')
    if os.path.exists(idfile):
        with open(idfile, 'r') as fp:
            device_id = fp.read().strip()
            return device_id

    # Id file doesn't exist. We either migrate it from ccnet.conf ID
    # (for existing data), or create it.

    if os.path.exists(ccnet_conf):
        # migrate from existing ccnet.conf ID
        with open(ccnet_conf, 'r') as fp:
            for line in fp:
                m = re.search('ID = (.*)', line)
                if m:
                    device_id = m.group(1)
                    print('Migrating device id from ccnet conf')
                    break
    if not device_id:
        # create a new id
        print('New device id created')
        device_id = randstring(40)
    with open(idfile, 'w') as fp:
        fp.write(device_id)
    return device_id

def urlopen(url, data=None, headers=None):
    if data:
        data = urllib.urlencode(data)
    headers = headers or {}
    req = urllib2.Request(url, data=data, headers=headers)
    resp = urllib2.urlopen(req)
    return resp.read()

def get_repo_download_info(url, token):
    headers = { 'Authorization': 'Token %s' % token }
    repo_info = urlopen(url, headers = headers)
    return json.loads(repo_info)

def get_token(url, username, password, tfa, fs):
    platform = 'linux'
    device_id = get_device_id(fs)
    device_name = 'terminal-' + os.uname()[1]
    client_version = ''
    platform_version = ''
    data = {
        'username': username,
        'password': password,
        'platform': platform,
        'device_id': device_id,
        'device_name': device_name,
        'client_version': client_version,
        'platform_version': platform_version,
    }
    if tfa:
        headers = {
            'X-SEAFILE-OTP': tfa,
        }
    else:
        headers = None
    token_json = urlopen("%s/api2/auth-token/" % url, data=data, headers=headers)
    tmp = json.loads(token_json)
    token = tmp['token']
    return token

def seaf_listremote(username, password):
    url = 'http://kooplex-test-seafile/seafile'
    fs = FS(username)
    seafile_rpc = seafile.RpcClient(fs.seaf_sock)
    username__ = "j@https://kooplex-test.elte.hu/hydra" #FIXME
    token = get_token(url, username__, password, None, fs)
    return get_repo_download_info("%s/api2/repos/" % (url), token)

@app.route('/api/sync/listremote/<username>/<password>')
@auth.login_required
def get_sync_listremote(username, password):
    try:
        result = sudo(username, seaf_listremote, username, password)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(result) })


def seaf_listlocal(username):
    fs = FS(username)
    seafile_rpc = seafile.RpcClient(fs.seaf_sock)
    return seafile_rpc.get_repo_list(-1, -1)

@app.route('/api/sync/listlocal/<username>')
@auth.login_required
def get_sync_listlocal(username):
    try:
        result = sudo(username, seaf_listlocal, username)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(result) })



def seaf_sync(username, password, libraryid, librarypassword):
    url = 'http://kooplex-test-seafile/seafile'
    fs = FS(username)
    seafile_rpc = seafile.RpcClient(fs.seaf_sock)



    username__ = "j@https://kooplex-test.elte.hu/hydra" #FIXME
    token = get_token(url, username__, password, None, fs)
    tmp = get_repo_download_info("%s/api2/repos/%s/download-info/" % (url, libraryid), token)

    folder = os.path.join(fs.seaf_path, tmp['repo_name'])
    if not os.path.isdir(folder):
        os.mkdir(folder)

    encrypted = tmp['encrypted']
    magic = tmp.get('magic', None)
    enc_version = tmp.get('enc_version', None)
    random_key = tmp.get('random_key', None)

    clone_token = tmp['token']
    relay_id = tmp['relay_id']
    relay_addr = tmp['relay_addr']
    relay_port = str(tmp['relay_port'])
    email = tmp['email']
    repo_name = tmp['repo_name']
    version = tmp.get('repo_version', 0)
    repo_salt =  tmp['salt']
    is_readonly = None
    if 'permission' in tmp.keys():
        is_readonly = tmp['permission']

    more_info = None
    more_info_dict = {'server_url': 'http://kooplex-test-seafile/' } #BASEURL
    if repo_salt:
        more_info_dict.update({'repo_salt': repo_salt})
    if is_readonly:
        more_info_dict.update({'is_readonly': is_readonly})
    if more_info_dict:
        more_info = json.dumps(more_info_dict)

    if encrypted == 1:
        repo_passwd = librarypassword
    else:
        repo_passwd = None

    seafile_rpc.clone(libraryid,
                      version,
                      relay_id,
                      repo_name.encode('utf-8'),
                      folder,
                      clone_token,
                      repo_passwd, magic,
                      relay_addr,
                      relay_port,
                      email, random_key, enc_version, more_info)
    return folder


@app.route('/api/sync/sync/<username>/<password>/<libraryid>/<librarypassword>')
@auth.login_required
def get_sync_sync(username, password, libraryid, librarypassword):
    try:
        result = sudo(username, seaf_sync, username, password, libraryid, librarypassword)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(result) })


def seaf_desync(username, libraryid):
    fs = FS(username)
    seafile_rpc = seafile.RpcClient(fs.seaf_sock)

    #repos = seafile_rpc.get_repo_list(-1, -1)
    repos = seafile_rpc.get_clone_tasks()
    print (repos)
    for r in repos:
        print (dir(r))
        print (r.worktree, r.id, r._dict)

    seafile_rpc.remove_repo(libraryid)
    return "OK"

@app.route('/api/sync/desync/<username>/<libraryid>')
@auth.login_required
def get_sync_desync(username, libraryid):
    try:
        result = sudo(username, seaf_desync, username, libraryid)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(result) })

if __name__ == '__main__':
    app.run(debug = True, host = '0.0.0.0')
