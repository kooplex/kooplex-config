FROM kooplex-notebook-base


# Install dashboard layout and preview within Jupyter Notebook
#RUN pip install "jupyter_dashboards==0.6.1" && \
#        jupyter dashboards quick-setup --sys-prefix


RUN conda config --add channels conda-forge

RUN  $CONDA_DIR/bin/conda install --quiet --yes jupyter_dashboards==0.6.1 && \
     jupyter dashboards quick-setup --sys-prefix

# Install declarative widgets for Jupyter Notebook
#ARG DECLWIDGETS_VER
#RUN pip install "jupyter_declarativewidgets==$DECLWIDGETS_VER" && \
#        jupyter declarativewidgets quick-setup --sys-prefix

# Install content management to support dashboard bundler options
#RUN pip install "jupyter_cms==5.1.5" && \
#        jupyter cms quick-setup --sys-prefix
#RUN pip install "jupyter_dashboards_bundlers==0.8.0" && \
#        jupyter dashboards_bundlers quick-setup --sys-prefix

RUN  $CONDA_DIR/bin/conda install --quiet --yes jupyter_cms==0.6.2 && \
     jupyter cms quick-setup --sys-prefix

#RUN  $CONDA_DIR/bin/conda install --quiet --yes jupyter_dashboards_bundlers==0.7.0 && \
#     jupyter dashboards_bundlers quick-setup --sys-prefix

# Add local files as late as possible to avoid cache busting
ADD scripts/start-notebook.sh /usr/local/bin/start-notebook.sh
ADD scripts/start-singleuser.sh /usr/local/bin/start-singleuser.sh

