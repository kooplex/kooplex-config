#!/usr/bin/env python

import sys
import logging
from flask import Flask, jsonify, request
from flask_httpauth import HTTPBasicAuth

from seafile_functions import start_sync, stop_sync, mkdir_parent
from git_functions import clone_repo, rmdir_repo, mkdir_repo

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

@app.route('/api/sync/sync/<username>/<password>/<libraryid>/<librarypassword>')
@auth.login_required
def get_sync_sync(username, password, libraryid, librarypassword):
    try:
        mkdir_parent(username)
        response = start_sync(username, password, libraryid, librarypassword)
    except Exception as e:
        logger.error('oops start sync: {} for {} -- {}'.format(libraryid, username, e))
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(response), 'sync_folder': response })

@app.route('/api/sync/desync/<username>/<libraryid>')
@auth.login_required
def get_sync_desync(username, libraryid):
    try:
        response = stop_sync(username, libraryid)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(response) })


@app.route('/api/versioncontrol/clone/<username>')
@auth.login_required
def get_versioncontrol_clone(username):
    try:
        assert username == request.args.get('username'), 'hacker go away'
        url_clone_repo = request.args.get('clone')
        port = request.args.get('port')
        prefix = request.args.get('prefix')
        folder = '\\'.join([ prefix, username, url_clone_repo.split(':')[-1].replace('/', '\\') ])
        rsa = request.args.get('rsa_file')
        if folder.endswith('.git'):
            folder = folder[:-4]
        mkdir_repo(username, folder)
        response = clone_repo(username, rsa, url_clone_repo, port, folder)
    except Exception as e:
        logger.error(e)
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(response), 'clone_folder': folder })

@app.route('/api/versioncontrol/removecache/<username>')
@auth.login_required
def get_versioncontrol_removecache(username):
    try:
        assert username == request.args.get('username'), 'hacker go away'
        url_clone_repo = request.args.get('clone')
        prefix = request.args.get('prefix')
        folder = '\\'.join([ prefix, username, url_clone_repo.split(':')[-1].replace('/', '\\') ])
        if folder.endswith('.git'):
            folder = folder[:-4]
        rmdir_repo(folder)
    except Exception as e:
        logger.error(e)
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': 'removed folder {}'.format(folder) })

if __name__ == '__main__':
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    app.run(debug = True, host = '0.0.0.0')
