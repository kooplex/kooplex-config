# Pod definitions

```python
pod_definition = {
            "apiVersion": "v1",
            "kind": "Pod",
            "metadata": {
                "name": "tst-nb",
                "namespace": "default",
                "labels": {
                    "lbl": "lbl-tst-nb",
                }
            },
            "spec": {
                "containers": [{
                    "name": "tst-nb",
                    "image": "kooplex-test:5000/k8plex-basic",
                    "volumeMounts": [{
                        "name": "pv-k8plex-hub-home",
                        "mountPath": "/v/home",
#                        "subPath": "username"
                    }],
                    "ports": [{
                        "containerPort": 8000,
                        "name": "http",
                    },],
                    "imagePullPolicy": "IfNotPresent",
                    "env": [
                      { "name": "LANG", "value": "en_US.UTF-8" },
                      { "name": "PREFIX", "value": "k8plex" },
                    ],
                }],
                "volumes": [{
                    "name": "pv-k8plex-hub-home",
                    "persistentVolumeClaim": {
                        "claimName": "pvc-home-k8plex",
                    }
                }]
            }
        }
```

# Service definitions

```python
svc_definition = {
            "apiVersion": "v1",
            "kind": "Service",
            "metadata": {
                "name": "tst-nb",
            },
            "spec": {
                "selector": {
                    "name": "lbl-tst-nb",
                    },
                "ports": [{
                        "port": 8000,
                        "targetPort": 8000,
                 #       "name": "http",
                        "protocol": "TCP",
                }],
            }
        }
```

# Manifestation

Make sure kobe config file in `~/.kube/config` is present.

```python
from kubernetes import client, config
config.load_kube_config()
v1 = client.CoreV1Api()

resp_svc = v1.create_namespaced_service(namespace = "default", body = svc_definition)
resp_pod = v1.create_namespaced_pod(namespace = "default", body = pod_definition)
```

Response is an onbject with all necessary details.

# Deletion

```python
resp_pod = v1.delete_namespaced_pod(namespace = "default", name = "tst-nb")
resp_svc = v1.delete_namespaced_service(namespace = "default", name = "tst-nb")
```

