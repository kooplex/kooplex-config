#!/usr/bin/env python

import sys, subprocess
import logging
from flask import Flask, jsonify, request
from flask_httpauth import HTTPBasicAuth

app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'
auth = HTTPBasicAuth()

CONF_DIR="/etc/nginx/conf.d/sites-enabled/"
#CONF_DIR="/tmp"

@auth.verify_password
def verify_password(username, password):
    # Note: token base example at https://blog.miguelgrinberg.com/post/restful-authentication-with-flask
    return True if (username == 'hub') and (password == 'blabla') else False

def restart_nginx_server():


@app.route('/')
def get_alive():
    return jsonify({'message': 'NGINX API server is running'})

@app.route('/api/new/<service>')
@auth.login_required
def get_sync_sync(service):
    try:
        service_conf = "%s/%s" % (CONF_DIR, service)
        with open(service_conf, 'w') as f:
            f.write("DDD")
            
        response = "Service %s started" % service
    except Exception as e:
        logger.error('Creating conf file for %s failed %s' %(service, e))
        return jsonify({ 'error': str(e) })
    try:
        subprocess.call("service nginx restart", shell=True)
    except Exception as e:
        logger.error('Nginx server could not be restarted %s' %( e))
        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(response), 'service add': response })

@app.route('/api/remove/<service>')
@auth.login_required
def get_sync_sync(service):
    try:
        service_conf = "%s/%s" % (CONF_DIR, service)
        os.remove(service_conf)    
        response = "Service %s ha been removed " % service
    except Exception as e:
        logger.error('Removing conf file for %s failed %s' %(service, e))
        return jsonify({ 'error': str(e) })
#    try:
#        subprocess.call("service nginx restart", shell=True)
#    except Exception as e:
#        logger.error('Nginx server could not be restarted %s' %( e))
#        return jsonify({ 'error': str(e) })
    return jsonify({ 'response': str(response), 'service removalr': response })

if __name__ == '__main__':
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    app.run(debug = True, host = '0.0.0.0')
