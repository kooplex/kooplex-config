FROM kooplex-base

RUN apt update && \
    apt install -y curl && \
    curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash - && \
    apt install --yes nodejs npm && \
    npm install -g bower

RUN apt install -y tmux zip curlftpfs
RUN apt install -y liblapack-dev libblas-dev
RUN apt install -y gfortran libfreetype6* pkg-config
RUN apt install -y git gcc mpi-default-dev mpi-default-bin libfftw3-dev fftw3 cmake


# TODO add jupyter stuff
# Configure environment
ENV CONDA_VER "latest"
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Create conda dir
RUN mkdir -p $CONDA_DIR

# Maybe this one is not needed, since you can create conda envs into volumes
RUN chmod a+wrx $CONDA_DIR    


# Install conda
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-$CONDA_VER-Linux-x86_64.sh && \
    # echo "9ea57c0fdf481acf89d816184f969b04bc44dea27b258c4e86b1e3a25ff26aa0 *Miniconda3-3.19.0-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash Miniconda3-$CONDA_VER-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-$CONDA_VER-Linux-x86_64.sh 

# WE NEED THIS TO BE ABLE TO RUN NOTEBOOK-SERVER WITHOUT ANY EXTERNAL VOLUME/MODUL etc...
RUN $CONDA_DIR/bin/conda install --quiet --yes  jupyter_core jupyter_client jupyter_console 
RUN $CONDA_DIR/bin/conda install --quiet --yes  notebook widgetsnbextension
#RUN  $CONDA_DIR/bin/conda install --quiet --yes pandas numpy scipy matplotlib seaborn plotly  bokeh pymysql sqlite ujson
#RUN  $CONDA_DIR/bin/conda install --quiet --yes -c conda-forge  igraph lifelines
#RUN  $CONDA_DIR/bin/conda install --quiet --yes -c conda-forge jupyter_dashboards && \
#     jupyter dashboards quick-setup --sys-prefix
#RUN  $CONDA_DIR/bin/conda install --quiet --yes -c conda-forge jupyter_cms && \
#     jupyter cms quick-setup --sys-prefix


# TO SWITCH BETWEEN CONDA ENVS
RUN pip install environment_kernels

# THIS IS VERY IMPORTANT !!!! 
# WITHOUT THIS IPYWIDGETS WON'T WORK
#RUN $CONDA_DIR/bin/conda install -c conda-forge ipywidgets
WORKDIR /tmp
RUN git clone https://github.com/jupyter-widgets/ipywidgets.git 
WORKDIR /tmp/ipywidgets/
#RUN git reset  96450b6
RUN  pip install -e .
RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix
# THIS IS VERY IMPORTANT !!!! 


# This one is not needed as long as it cannot discover conda envs outside of /opt/conda
#RUN $CONDA_DIR/bin/conda install --quiet --yes nb_conda nb_conda_kernels

# Add local files as late as possible to avoid cache busting
ADD start-notebook.sh /usr/local/bin/start-notebook.sh





