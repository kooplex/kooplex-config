for moduledir in `ls /vol/*/condaenvs/*/ -d`
do
modulename=`basename $moduledir`
cp -r /opt/conda/share/jupyter/kernels/python3   /opt/conda/share/jupyter/kernels/conda_$modulename
moduledir_escaped=$(echo $moduledir | sed s"/\//\\\\\//"g)
sed -i "s/python/$moduledir_escaped\/bin\/python/" /opt/conda/share/jupyter/kernels/conda_$modulename/kernel.json
done

# run kernel the gateway
jupyter kernelgateway --KernelGatewayApp.ip=0.0.0.0
