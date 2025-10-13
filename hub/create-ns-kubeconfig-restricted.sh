export NAMESPACE_STOREMAP=`grep " ns:" ../config.libsonnet| awk '{print $2}' | sed -e "s/'//g" -e 's/,//'`
export ALLCONF_TARGET="/home/kooplex-admin/kubeconfig.yaml"

kubectl delete configmap kubeconfig -n ${NAMESPACE_STOREMAP}
kubectl create configmap kubeconfig -n ${NAMESPACE_STOREMAP} --from-file=kubeconfig=${ALLCONF_TARGET}


