import os, sys, subprocess
import logging
from flask import Flask, jsonify, request
from flask_httpauth import HTTPBasicAuth

app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'
auth = HTTPBasicAuth()

CONF_DIR="/etc/nginx/conf.d/sites-enabled/"
NGINX_USER=os.getenv("NGINX_API_USER")
NGINX_PW=os.getenv("NGINX_API_PW")

@auth.verify_password
def verify_password(username, password):
    # Note: token base example at https://blog.miguelgrinberg.com/post/restful-authentication-with-flask
    return True if (username == NGINX_USER) and (password == NGINX_PW) else False

def start_nginx_server():
    command = 'service nginx start';
    try:
        subprocess.call(command, shell=True)
    except Exception as e:
        logger.error('Starting nginx failed with error %s' %( e))
        return jsonify({ 'error': str(e) })

def reload_nginx_server():
    command = 'service nginx reload';
    try:
        subprocess.call(command, shell=True)
    except Exception as e:
        logger.error('Reloading nginx failed with error %s' %( e))
        return jsonify({ 'error': str(e) })



@app.route('/')
def get_alive():
    return jsonify({'message': 'NGINX API server is running'})

            
@app.route('/api/new/<service>', methods = ['POST'])
@auth.login_required
def create_new_service(service):
    try:
        service_conf = "%s/%s" % (CONF_DIR, service)
        with open(service_conf, 'wb') as f:
             f.write(request.data)
    except Exception as e:
        logger.error('Creating conf file for %s failed %s' %(service, e))
        return jsonify({ 'error': str(e) })

    reload_nginx_server()
    response = "Service %s started" % service
    return jsonify({ 'response': str(response), 'service add': response })

@app.route('/api/remove/<service>')
@auth.login_required
def remove_new_service(service):
    try:
        service_conf = "%s/%s" % (CONF_DIR, service)
        os.remove(service_conf)    
    except Exception as e:
        logger.error('Removing conf file for %s failed %s' %(service, e))
        return jsonify({ 'error': str(e) })

    reload_nginx_server()
    response = "Service %s has been removed " % service
    return jsonify({ 'response': str(response), 'service removal': response })

if __name__ == '__main__':
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    start_nginx_server()

    app.run(debug = True, host = '0.0.0.0')
