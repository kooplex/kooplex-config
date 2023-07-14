export KUBERNETES_MASTER="k8s-controlplane:6443"
export NAMESPACE_STOREMAP=`grep " ns:" ../config.libsonnet| awk '{print $2}' | sed -e "s/'//g" -e 's/,//'`
export POD_NAMESPACE=$NAMESPACE_STOREMAP"-pods"
export JOB_NAMESPACE=$NAMESPACE_STOREMAP"-jobs"
echo $POD_NAMESPACE
echo $JOB_NAMESPACE
export K8S_USER="hub"
export CONF_TARGET="etc/kube.conf"

kubectl create namespace ${POD_NAMESPACE}
kubectl create namespace ${JOB_NAMESPACE}

export KUBERNETES_MASTER="k8s-controlplane:6443"
export NAMESPACE_STOREMAP=`grep " ns:" ../config.libsonnet| awk '{print $2}' | sed -e "s/'//g" -e 's/,//'`
export K8S_USER="hub"
export ALLCONF_TARGET="etc/allkube.conf"

mkdir -p manifest

cat << EOF > manifest/hub_kubeconfig.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${K8S_USER}
  namespace: ${NAMESPACE_STOREMAP}
EOF

cat <<EOF >> manifest/hub_kubeconfig.yaml
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-reader-v1-${NAMESPACE_STOREMAP}
rules:
- apiGroups: ["", "extensions", "apps", "metrics.k8s.io"]
  resources: ["pods","nodes", "secrets"]
  verbs: ["get", "list", "watch"]
EOF

cat <<EOF >> manifest/hub_kubeconfig.yaml
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-cluster-v1-${NAMESPACE_STOREMAP}
subjects:
- kind: ServiceAccount
  name: ${K8S_USER}
  namespace: ${NAMESPACE_STOREMAP}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-reader-v1-${NAMESPACE_STOREMAP}
EOF


cat <<EOF >> manifest/hub_kubeconfig.yaml
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-writer-v1-${NAMESPACE_STOREMAP}
rules:
- apiGroups: ["*", "extensions", "apps", "batch"]
  resources: ["*"]
  verbs: ["*"]
EOF

cat <<EOF >> manifest/hub_kubeconfig.yaml
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: write-cluster-v1-${NAMESPACE_STOREMAP}
  namespace: ${JOB_NAMESPACE}
subjects:
- kind: ServiceAccount
  name: ${K8S_USER}
  namespace: ${NAMESPACE_STOREMAP}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-writer-v1-${NAMESPACE_STOREMAP}
EOF

cat <<EOF  >> manifest/hub_kubeconfig.yaml
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: write-cluster-v1-${NAMESPACE_STOREMAP}
  namespace: ${POD_NAMESPACE}
subjects:
- kind: ServiceAccount
  name: ${K8S_USER}
  namespace: ${NAMESPACE_STOREMAP}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-writer-v1-${NAMESPACE_STOREMAP}
EOF


kubectl apply -f manifest/hub_kubeconfig.yaml

TOKEN=$(kubectl -n ${NAMESPACE_STOREMAP} describe secret $(kubectl -n ${NAMESPACE_STOREMAP} get secret | (grep ${K8S_USER} || echo "$_") | awk '{print $1}') | grep token: | awk '{print $2}')
CERT=$(kubectl  -n ${NAMESPACE_STOREMAP} get secret `kubectl -n ${NAMESPACE_STOREMAP} get secret | (grep ${K8S_USER} || echo "$_") | awk '{print $1}'` -o "jsonpath={.data['ca\.crt']}")
CAD=$(grep certificate-authority-data ~/.kube/config | cut -f2 -d:)


mkdir -p etc 

cat > ${ALLCONF_TARGET} << EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CAD}
    server: https://${KUBERNETES_MASTER}
  name: kubernetes


contexts:
- context:
    cluster: kubernetes
    namespace: ${NAMESPACE_STOREMAP}
    user: ${K8S_USER}
  name: ${NAMESPACE_STOREMAP}

current-context: ${NAMESPACE_STOREMAP}
kind: Config
preferences: {}


users:
- name: ${K8S_USER}
  user:
    token: $TOKEN
    client-key-data: $CERT
EOF

kubectl delete configmap kubeconfig -n ${NAMESPACE_STOREMAP}
kubectl create configmap kubeconfig -n ${NAMESPACE_STOREMAP} --from-file=kubeconfig=${ALLCONF_TARGET}


