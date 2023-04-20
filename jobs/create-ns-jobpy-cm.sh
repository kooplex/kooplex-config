export NAMESPACE_STOREMAP=`grep " ns:" ../config.libsonnet| awk '{print $2}' | sed -e "s/'//g" -e 's/,//'`
export NAMESPACE=$NAMESPACE_STOREMAP"-pods"

cd scripts
kubectl create configmap job.py -n ${NAMESPACE} --from-file=job="job.py"
