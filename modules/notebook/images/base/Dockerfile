FROM kooplex-base

MAINTAINER Laszlo Dobos <dobos@complex.elte.hu

# Configure environment
ENV SHELL /bin/bash
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install jupyter, pip, etc. and upgrade pip
# Install JupyterHub to get the jupyterhub-singleuser startup script
RUN apt-get update \
	&& apt-get install -y python3 python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir jupyter jupyterhub
    
# Also install dashboard extensions
RUN pip3 install --no-cache-dir 'jupyter_dashboards' \
	&& jupyter-dashboards quick-setup \
	&& jupyter-nbextension enable jupyter_dashboards --py
	
# Add local files as late as possible to avoid cache busting
ADD start-notebook.sh /usr/local/bin/start-notebook.sh
ADD start-singleuser.sh /usr/local/bin/start-singleuser.sh
