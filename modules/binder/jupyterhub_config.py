# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Configuration file for JupyterHub
import os
import dockerspawner

c = get_config()

# We rely on environment variables to configure JupyterHub so that we
# avoid having to rebuild the JupyterHub container every time we change a
# configuration parameter.
class FormSpawner(dockerspawner.DockerSpawner):
    def _options_form_default(self):
        default_env = "INTERESTING_REPOSITORY=https://github.com/icsabai/gRNAdesign.git" 
        return """
       <label for="env">Git repository you are interested in</label>
        <textarea name="env">{env}</textarea>
        """.format(env=default_env)
    
    def options_from_form(self, formdata):
        options = {}
        options['env'] = env = {}
        
        env_lines = formdata.get('env', [''])
        for line in env_lines[0].splitlines():
            if line:
                key, value = line.split('=', 1)
                env[key.strip()] = value.strip()
        
        arg_s = formdata.get('args', [''])[0].strip()
        if arg_s:
            options['argv'] = shlex.split(arg_s)
        return options
    
    def get_args(self):
        """Return arguments to pass to the notebook server"""
        argv = super().get_args()
        if self.user_options.get('argv'):
            argv.extend(self.user_options['argv'])
        return argv
    
    def get_env(self):
        env = super().get_env()
        if self.user_options.get('env'):
            env.update(self.user_options['env'])
        return env
# Spawn single-user servers as Docker containers
#c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
c.JupyterHub.spawner_class = FormSpawner
# Spawn containers from this image
#c.DockerSpawner.container_image = os.environ['DOCKER_NOTEBOOK_IMAGE']
c.DockerSpawner.container_image = 'kooplexbindersingleuser'

# JupyterHub requires a single-user instance of the Notebook server, so we
# default to using the `start-singleuser.sh` script included in the
# jupyter/docker-stacks *-notebook images as the Docker run command when
# spawning containers.  Optionally, you can override the Docker run command
# using the DOCKER_SPAWN_CMD environment variable.
#spawn_cmd = os.environ.get('DOCKER_SPAWN_CMD', "start-singleuser.sh")
spawn_cmd = os.environ.get('DOCKER_SPAWN_CMD', "/srv/singleuser/singleuser.sh")
#spawn_cmd = os.environ.get('DOCKER_SPAWN_CMD', "/home/main/start-notebook.sh")
c.DockerSpawner.extra_create_kwargs.update({ 'command': spawn_cmd })
# Connect containers to this Docker network
network_name = 'kooplexbinder_hubnet'
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name
# Pass the network name as argument to spawned containers
c.DockerSpawner.extra_host_config = { 'network_mode': network_name }
c.DockerSpawner.extra_start_kwargs = { 'network_mode': network_name }
# Explicitly set notebook directory because we'll be mounting a host volume to
# it.  Most jupyter/docker-stacks *-notebook images run the Notebook server as
# user `jovyan`, and set the notebook directory to `/home/jovyan/work`.
# We follow the same convention.
notebook_dir =  '/home/jovyan/work'
# Remove containers once they are stopped
c.DockerSpawner.remove_containers = True
# For debugging arguments passed to spawned containers
c.DockerSpawner.debug = True

# User containers will access hub by container name on the Docker network
c.JupyterHub.hub_ip = 'binderhub'
c.JupyterHub.hub_port = 8080

# TLS config
c.JupyterHub.port = 443
c.JupyterHub.ssl_key = os.environ['SSL_KEY']
c.JupyterHub.ssl_cert = os.environ['SSL_CERT']

