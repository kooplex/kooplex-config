# Follow 
# https://jeremievallee.com/2018/05/28/kubernetes-rbac-namespace-user.html
# or
# https://computingforgeeks.com/restrict-kubernetes-service-account-users-to-a-namespace-with-rbac/

kubectl create ns kooplex-usersvcs

export KUBERNETES_MASTER="controlplane"
export NAMESPACE="kooplex-usersvcs"
export K8S_USER="hub"

# Create access.yaml
#kubectl create -f access.yaml

# Create access.yaml
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

cat > kube.config << EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: << COPY FROM kube.config >>
    server: https://${KUBERNETES_MASTER}
  name: kubernetes


contexts:
- context:
    cluster: kubernetes
    namespace: ${NAMESPACE}
    user: ${K8S_USER}
  name: ${K8S_USER}

current-context: hub
kind: Config
preferences: {}


users:
- name: ${K8S_USER}
  user:
    token: $TOKEN
    client-key-data: $CERT
EOF

