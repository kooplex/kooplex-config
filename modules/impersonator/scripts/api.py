#!/usr/bin/env python

import sys
import logging
import pickle
import base64
import subprocess
from flask import Flask, jsonify, request
from flask_httpauth import HTTPBasicAuth

from seafile_functions import start_sync, stop_sync, mkdir_parent, rmcache_sync
from git_functions import clone_repo, rmdir_repo, mkdir_repo, clone_folder

app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'
auth = HTTPBasicAuth()

@auth.verify_password
def verify_password(username, password):
    # Note: token base example at https://blog.miguelgrinberg.com/post/restful-authentication-with-flask
    return True if (username == 'hub') and (password == 'blabla') else False

@app.route('/')
def get_alive():
    return jsonify({'message': 'API server is running'})

@app.route('/api/sync/<data>')
@auth.login_required
def get_sync(data):
    data_dict = None
    try:
        data_dict = pickle.loads(base64.b64decode(eval(data)))
        if data_dict['do'] == 'start':
            mkdir_parent(data_dict['username'], data_dict['service_url'])
            response = start_sync(data_dict['username'], data_dict['service_url'], data_dict['password'], data_dict['libraryid'], data_dict['librarypassword'])
            return jsonify({ 'response': str(response), 'sync_folder': response })
        elif data_dict['do'] == 'stop':
            response = stop_sync(data_dict['username'], data_dict['service_url'], data_dict['libraryid'])
            return jsonify({ 'response': str(response) })
        elif data_dict['do'] == 'drop':
            response1 = stop_sync(data_dict['username'], data_dict['service_url'], data_dict['libraryid'])
            response2 = rmcache_sync(data_dict['username'], data_dict['service_url'], data_dict['password'], data_dict['libraryid'])
            return jsonify({ 'response': { 'stop_sync': str(response1), 'rmcache_sync': str(response2) } })
        else:
            raise Exception('wrong parameter passed')
    except Exception as e:
        logger.error('oops start sync: {data} --> {data_dict} -- {e}'.format(data = data, data_dict = data_dict, e = e))
        return jsonify({ 'error': str(e) })


#FIXME: @auth.login_required
@app.route('/api/register_git/<service>')
def get_register_git(service):
    try:
        if ':' in service:
            service, port = service.split(':')
            cmd = [ 'ssh-keyscan', '-p', port, '-H', service ]
        else:
            cmd = [ 'ssh-keyscan', '-H', service ]
        proc = subprocess.Popen(cmd, stdout = subprocess.PIPE)
        kh = proc.stdout.read()
        open('/etc/ssh/ssh_known_hosts', 'a').write(kh)
        proc_ret = proc.returncode
        logger.info('wrote known_host info for {}, exit code: {}'.format(service, proc_ret))
        return jsonify({ 'status': 'ok' })
    except Exception as e:
        logger.error('oops registering: {} cmd {} -- {}'.format(service, cmd, e))
        return jsonify({ 'error': str(e) })

@app.route('/api/versioncontrol/<data>')
@auth.login_required
def get_versioncontrol(data):
    data_dict = None
    try:
        data_dict = pickle.loads(base64.b64decode(eval(data)))
        if data_dict['do'] == 'clone':
            mkdir_repo(data_dict['username'], data_dict['service_url'])
            response = clone_repo(data_dict['username'], data_dict['rsa'], data_dict['service_url'], data_dict['url_clone_repo'])
            folder = clone_folder(data_dict['url_clone_repo'])
            logger.debug('response: {}, folder: {}'.format(response, folder))
            return jsonify({ 'response': str(response), 'clone_folder': folder })
        if data_dict['do'] == 'drop':
            folder = rmdir_repo(data_dict['username'], data_dict['service_url'], data_dict['url_clone_repo'])
            logger.debug('removed folder: {}'.format(folder))
            return jsonify({ 'response': 'ok', 'removed_folder': folder })
        else:
            raise Exception('wrong parameter passed')
    except Exception as e:
        logger.error('oops: {data} --> {data_dict} -- {e}'.format(data = data, data_dict = data_dict, e = e))
        return jsonify({ 'error': str(e) })


if __name__ == '__main__':
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    handler = logging.FileHandler('/var/log/api/api.log')
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    app.run(debug = True, host = '0.0.0.0')
