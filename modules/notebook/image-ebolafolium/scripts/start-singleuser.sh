#!/bin/bash
set -e

notebook_arg=""
if [ -n "${NOTEBOOK_DIR:+x}" ]
then
    notebook_arg="--notebook-dir=${NOTEBOOK_DIR}"
fi

# nb-extension
jupyter nbextensions_configurator enable --system

jupyter nbextension enable codefolding/main
jupyter nbextension enable hide_input/main
jupyter nbextension enable hide_input_all/main


exec jupyterhub-singleuser \
  --port=8888 \
  --ip=0.0.0.0 \
  --user=$JPY_USER \
  --cookie-name=$JPY_COOKIE_NAME \
  --base-url=$JPY_BASE_URL \
  --hub-prefix=$JPY_HUB_PREFIX \
  --hub-api-url=$JPY_HUB_API_URL \
  ${notebook_arg} \
  $@

