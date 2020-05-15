import os, sys, subprocess
import json
import logging
from flask import Flask, jsonify, request
from flask_httpauth import HTTPBasicAuth

app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'
auth = HTTPBasicAuth()

CONF_DIR="/etc/hydraconfig/"
SECRET_DIR="/etc/secrets/"
HYDRA_USER=os.getenv("HYDRA_API_USER")
#HYDRA_USER="hydrauser"

HYDRA_PW=os.getenv("HYDRA_API_PW")
#HYDRA_PW="hydrapw"

@auth.verify_password
def verify_password(username, password):
    # Note: token base example at https://blog.miguelgrinberg.com/post/restful-authentication-with-flask
    return True if (username == HYDRA_USER) and (password == HYDRA_PW) else False

@app.route('/')
def get_alive():
    return jsonify({'message': 'HYDRA API server is running'})

def new_hydra_service(method, conffile):
    command = 'hydra %s import %s'%(method, conffile);
    try:
        output = subprocess.check_output(command, shell=True)
        logger.debug(output)
        return output
    except Exception as e:
        logger.error('Importing %s %s  failed with error %s' %(method, conffile, e))
        return jsonify({ 'error': str(e) })

def remove_hydra_service(method, service): 
    command = 'hydra %s delete %s'%(method, service);     
    try:                                                   
        output = subprocess.check_output(command, shell=True)
        logger.debug(output)
    except Exception as e:      
        logger.error('Removing %s %s  failed with error %s' %(method, service, e))       
        return jsonify({ 'error': str(e) }) 
            
@app.route('/api/new-client/<service>', methods = ['POST'])
@auth.login_required
def create_client(service):
    try:
        data = request.data.decode()
        client_file = os.path.join(CONF_DIR, service+"-client")
        #write config
        with open(client_file, 'w') as f:
             f.write(data)
        rtn = new_hydra_service('clients', client_file)
        secret_file = os.path.join(SECRET_DIR, service+"-hydra.secret")
        with open(secret_file, 'w') as f:
             f.write(rtn.decode().split(":")[1].split()[0])
    except Exception as e:
        logger.error('Creating client file for %s failed %s' %(service, e))
        return jsonify({ 'error': str(e) })

    response = "Service %s is registered to hydra" % service
    return jsonify({ 'response': str(response), 'service add': response })

@app.route('/api/new-policy/<service>', methods = ['POST'])
@auth.login_required
def create_policy(service):
    try:
        data = request.data.decode()
        policy_file = os.path.join(CONF_DIR, service+"-policy")
        #write config
        with open(policy_file, 'w') as f:
             f.write(data)
        new_hydra_service('policies', policy_file)
    except Exception as e:
        logger.error('Creating policy file for %s failed %s' %(service, e))
        return jsonify({ 'error': str(e) })

    response = "Service %s is registered to hydra" % service
    return jsonify({ 'response': str(response), 'service add': response })

@app.route('/api/remove/<service>', methods = ['DELETE'])
@auth.login_required
def remove_service(service):
    try:
        rtn = remove_hydra_service('policies', service)
        rtn = remove_hydra_service('clients', service)

        secret_file = os.path.join(SECRET_DIR, service+"-hydra.secret")
        os.remove(secret_file)
        client_file = os.path.join(CONF_DIR, service+"-client")
        os.remove(client_file)
        policy_file = os.path.join(CONF_DIR, service+"-policy")
        os.remove(policy_file)
    except Exception as e:
        logger.error('Removing conf file for %s failed %s' %(service, e))
        return jsonify({ 'error': str(e) })

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

    app.run(debug = True, host = '0.0.0.0')
