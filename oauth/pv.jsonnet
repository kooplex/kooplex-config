local Config = import '../config.libsonnet';

{
  'pv.yaml-raw': {
    apiVersion: 'v1',
    kind: 'List',
    items:
      [
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
	      "path": Config.nfsvol+"/"+Config.oauth.appname,
	      "server": Config.nfsserver 
	    }
	  }
	}
  ]
 }
}
