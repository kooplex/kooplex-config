{
  "apiVersion": "v1",
  "kind": "PersistentVolume",
  "metadata": {
    "name": Config.oauth.appname
  },
  "spec": {
    "capacity": {
      "storage": "1Gi"
    },
    "volumeMode": "Filesystem",
    "accessModes": [
      "ReadWriteMany"
    ],
    "persistentVolumeReclaimPolicy": "Retain",
    "nfs": {
      "path": Config.nfspath+"/"Config.oauth.appname,
      "server": Config.nfsserver 
    }
  }
}
