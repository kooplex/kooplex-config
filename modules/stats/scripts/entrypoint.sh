service cron start

tini -- jupyter-kernelgateway --KernelGatewayApp.api=notebook-http --KernelGatewayApp.ip=0.0.0.0 --KernelGatewayApp.allow_origin=* --KernelGatewayApp.seed_uri=Monitordb-API.ipynb

