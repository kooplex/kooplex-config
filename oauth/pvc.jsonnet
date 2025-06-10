{
  "apiVersion": "v1",
  "kind": "PersistentVolumeClaim",
  "metadata": {
    "name": Config.oauth.appname+"-data",
    "namespace": Config.ns
  },
  "spec": {
    "accessModes": [
      "ReadWriteMany"
    ],
    "volumeMode": "Filesystem",
    "resources": {
      "requests": {
        "storage": "1Gi"
      }
    },
    "storageClassName": "",
    "volumeName": Config.oauth.appname
  }
}
