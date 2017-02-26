#!/bin/bash
# nb-extension
pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
jupyter contrib nbextension install --user
jupyter contrib nbextensions migrate
pip install jupyter_nbextensions_configurator --user
jupyter nbextensions_configurator enable --user

jupyter nbextension enable codefolding/main
jupyter nbextension enable hide_input/main
jupyter nbextension enable hide_input_all/main
