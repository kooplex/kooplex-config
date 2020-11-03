#! /usr/bin/env python

import os
import hashlib
from flask import Flask, jsonify
from flask_httpauth import HTTPBasicAuth
import pymysql


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

F = lambda bytestring: ''.join('{:02x}'.format(c) for c in bytestring)

def code_password_for_seafile(password):
    salt = os.urandom(32)
    key = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt, 10000)
    return "PBKDF2SHA256$10000$" + F(salt) +"$"+ F(key)

def store_user_pw(username, password):
    code = code_password_for_seafile(password)
    sqlq = "update EmailUser set passwd = '%s' where email = '%s';" % (code, username)
    dbhost = os.getenv('MYSQL_HOST', 'seafile-mysql')
    pw = os.getenv('MYSQL_ROOT_PASSWD')
    db = pymysql.connect(dbhost, "root", pw, "ccnet_db")
    c = db.cursor()
    c.execute(sqlq)
    c.close()
    db.commit()
    db.close()

@app.route('/api/setpass/<username>/<password>')
@auth.login_required
def get_setpass(username, password):
    try:
        store_user_pw(username, password)
    except Exception as e:
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': 'ok' })

if __name__ == '__main__':
    app.run(debug = True, host = '0.0.0.0')

