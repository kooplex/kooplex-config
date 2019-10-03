#!/usr/bin/env python

from flask import Flask, jsonify
from flask_httpauth import HTTPBasicAuth
import logging

from seafile_functions import start_sync, stop_sync

logger = logging.getLogger(__name__)
app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'

# extensions
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
        response = start_sync(username, password, libraryid, librarypassword)
    except Exception as e:
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


if __name__ == '__main__':
    app.run(debug = True, host = '0.0.0.0')
