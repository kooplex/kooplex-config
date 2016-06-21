import sys
from flask import Flask,redirect,request,Response
from webargs.flaskparser import use_args, parser
from webargs.flaskparser import FlaskParser as FL
import json
from webargs import fields
import docker
from time import sleep
from random import randint 
import socket
from io import BytesIO

docker_host_ip='127.0.0.1'
connect_to_ip='127.0.0.1'

#tls_config=docker.tls.TLSConfig(client_cert=('/tmp/cert.pem','/tmp/key.pem'))
#docli=docker.Client(base_url='tcp://%s:2376' %(docker_host_ip), tls=tls_config)
#docli=docker.Client(base_url='tcp://%s:2375' %(docker_host_ip) )
docli=docker.Client(base_url='unix:///var/run/docker.sock')

def launch_binder(args):
    """
    Simple function to spawn a container from an image and 
    bind container port 8888 to a predefined host port.
    """
    docli=args['docli']
    container = docli.create_container(image=args['image'],detach=True,
    host_config=docli.create_host_config(port_bindings={ 8888 : args['userport'] }),
    name='binder_user_at_'+str(args['userport']))
    docli.start(container)

    return container

parser = FL()
app = Flask(__name__)

   
@app.route('/launch',methods=['get'])
def getlinkinred():
    """
    Launch image and bind it to a random port and redirect to it. 
    """
    #find empty port
    is_port_used=True
    while is_port_used:
       port=randint(4000,9000)
       s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
       is_port_used = s.connect_ex((connect_to_ip, port))==0
       s.close()

    #determine the image to be run   
    image=request.args.get('image','jupyter/scipy-notebook')

    args={'image': image,
       'userport': port,
          'docli': docli}

    #EXECUTE LAUNCH FUNCTION
    result = launch_binder(args)
    sleep(2)   
    return redirect("http://%s:%d"%(connect_to_ip,args['userport']))

@app.route('/build',methods=['get'])
def buildimage():
    """
    Simple function to build image from git repo based on
    jupyter/scipy-notebook. If repo has requirements.txt file
    than install required packages.
    """
    # get link to git repo
    gitrepo=request.args.get('gitlink')
    # the name of the image is goingto be 'binder-<repo_name>' 
    tag='binder-'+gitrepo.rsplit('/',1)[-1].rsplit('.',1)[0]
    # a simple Dockerfile to build containers from
    dockerfile="""
FROM jupyter/scipy-notebook
RUN git clone %s notebooks
WORKDIR /home/jovyan/work/notebooks
USER root
RUN if [ -f requirements.txt ] ; then \
    pip install -r requirements.txt ; \
    else \
    echo "No additional packages installed" ; \
    fi; 
USER jovyan
    """%(gitrepo)
    f = BytesIO(dockerfile.encode('utf-8'))
    # build the image and format the output to be a human readable
    # html stream
    resp = map(
         lambda x:eval(str(x.decode('utf-8')))['stream']+'<br>',
         docli.build(fileobj=f, rm=True, tag=tag)
         )
    return Response(resp)

if __name__ == "__main__":
  app.run(host='127.0.0.1', port=9001, debug=True)

#  this works like this now:
#  127.0.0.1:9001/launch?image=IMAGENAME
#  127.0.0.1:9001/build?gitlink=GITREPO
