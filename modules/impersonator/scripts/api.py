#!/usr/bin/env python

import sys
import logging
from flask import Flask, jsonify
from flask_httpauth import HTTPBasicAuth

from seafile_functions import start_sync, stop_sync, mkdir_parent
from git_functions import clone_repo, mkdir_repo

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
        logger.error(e)
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(response) })

@app.route('/api/sync/desync/<username>/<libraryid>')
@auth.login_required
def get_sync_desync(username, libraryid):
    try:
        response = stop_sync(username, libraryid)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(response) })


@app.route('/api/versioncontrol/clone/<username>/<reponame>/<backend>/<server>/<port>')
@auth.login_required
def get_versioncontrol_clone(username, reponame, backend, server, port):
    try:
        mkdir_repo(username, backend, port, server, reponame)
        response = clone_repo(username, backend, server, port, reponame)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(response) })


if __name__ == '__main__':
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    app.run(debug = True, host = '0.0.0.0')
