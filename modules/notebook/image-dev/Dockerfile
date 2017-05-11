FROM kooplex-notebook-base


# Install dashboard layout and preview within Jupyter Notebook
#RUN pip install "jupyter_dashboards==0.6.1" && \
#        jupyter dashboards quick-setup --sys-prefix


RUN conda config --add channels conda-forge

RUN  $CONDA_DIR/bin/conda install --quiet --yes jupyter_dashboards && \
     jupyter dashboards quick-setup --sys-prefix

RUN  $CONDA_DIR/bin/conda install --quiet --yes jupyter_cms && \
     jupyter cms quick-setup --sys-prefix

RUN $CONDA_DIR/bin/conda install --quiet --yes pymysql
RUN $CONDA_DIR/bin/conda install --quiet --yes sqlite
RUN $CONDA_DIR/bin/conda install --quiet --yes ujson

RUN $CONDA_DIR/bin/conda install --quiet --yes nb_conda && \
    $CONDA_DIR/bin/conda install --quiet --yes nb_conda_kernels

RUN pip3 install sklearn-pandas

# R KERNEL

#RUN pip3 install rpy2


# Add local files as late as possible to avoid cache busting
ADD start-notebook.sh /usr/local/bin/start-notebook.sh

