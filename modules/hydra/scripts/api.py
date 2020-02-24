import os, sys, subprocess
import bcrypt, json
import logging
from flask import Flask, jsonify, request
from flask_httpauth import HTTPBasicAuth

app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'
auth = HTTPBasicAuth()

CONF_DIR="/etc/nginx/conf.d/sites-enabled/"
PW_DIR="/etc/passwords/"
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
        data = json.loads(request.data.decode().replace("\n","\\n"))
        service_conf = "%s/%s" % (CONF_DIR, service)
        #write config
        with open(service_conf, 'w') as f:
             f.write(data['conf'])
        #write password
        username = data['username']
#        password_e = data['password'].encode()
#        pw = bcrypt.hashpw(password_e, bcrypt.gensalt( 12 ))
        pw = "{PLAIN}%s"%data['password']
        pw_filename = os.path.join(PW_DIR, service)
        with open(pw_filename, 'w') as f:
            f.write("%s:%s"%(username, pw))
    except Exception as e:
        logger.error('Creating conf file for %s failed %s' %(service, e))
        return jsonify({ 'error': str(e) })

    reload_nginx_server()
    response = "Service %s started" % service
    return jsonify({ 'response': str(response), 'service add': response })

@app.route('/api/remove/<service>', methods = ['DELETE'])
@auth.login_required
def remove_service(service):
    try:
        service_conf = "%s/%s" % (CONF_DIR, service)
        os.remove(service_conf)    
        pw_file = "%s/%s" % (PW_DIR, service)
        os.remove(pw_file)
    except Exception as e:
        logger.error('Removing conf file for %s failed %s' %(service, e))
        return jsonify({ 'error': str(e) })

    reload_nginx_server()
    response = "Service %s ha been removed " % service
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
