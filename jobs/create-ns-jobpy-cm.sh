export NAMESPACE_STOREMAP=`grep " ns:" ../config.libsonnet| awk '{print $2}' | sed -e "s/'//g" -e 's/,//'`
export NAMESPACE=$NAMESPACE_STOREMAP"-pods"

cd scripts
kubectl get configmap job-py -n ${NAMESPACE}
if [ $? -eq 0 ] ; then
  echo "Configmap exists, deleting..."
  kubectl delete configmap job-py -n ${NAMESPACE}
fi
kubectl create configmap job-py -n ${NAMESPACE} --from-file=job="job.py"
