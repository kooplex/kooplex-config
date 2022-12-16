export KUBERNETES_MASTER="k8s-controlplane:6443"
export NAMESPACE_STOREMAP="k8plex-test"
export NAMESPACE="k8plex-test-jobs"
export K8S_USER="hub"
export CONF_TARGET="etc/jobs-kube.conf"

kubectl create namespace ${NAMESPACE}

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${K8S_USER}
  namespace: ${NAMESPACE}
EOF

cat <<EOF | kubectl apply -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: admin
  namespace: ${NAMESPACE}
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["*"]
EOF

cat <<EOF | kubectl apply -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: admin-view
  namespace: ${NAMESPACE}
subjects:
- kind: ServiceAccount
  name: ${K8S_USER}
  namespace: ${NAMESPACE}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: admin
EOF

TOKEN=$(kubectl -n ${NAMESPACE} describe secret $(kubectl -n ${NAMESPACE} get secret | (grep ${K8S_USER} || echo "$_") | awk '{print $1}') | grep token: | awk '{print $2}')
CERT=$(kubectl  -n ${NAMESPACE} get secret `kubectl -n ${NAMESPACE} get secret | (grep ${K8S_USER} || echo "$_") | awk '{print $1}'` -o "jsonpath={.data['ca\.crt']}")
CAD=$(grep certificate-authority-data ~/.kube/config | cut -f2 -d:)


mkdir -p etc 

cat > ${CONF_TARGET} << EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CAD}
    server: https://${KUBERNETES_MASTER}
  name: kubernetes


contexts:
- context:
    cluster: kubernetes
    namespace: ${NAMESPACE}
    user: ${K8S_USER}
  name: ${NAMESPACE}

current-context: ${NAMESPACE}
kind: Config
preferences: {}


users:
- name: ${K8S_USER}
  user:
    token: $TOKEN
    client-key-data: $CERT
EOF

kubectl create configmap kubejobsconfig -n ${NAMESPACE_STOREMAP} --from-file=kubejobsconfig=${CONF_TARGET}