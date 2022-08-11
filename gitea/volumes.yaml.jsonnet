local Config = import 'config.libsonnet';

{
  'pv_data.yaml-raw': Config.PV('gitea-data'),
  'pvc_data.yaml-raw': Config.PVC(Config.pvcname, pvname=$['pv_data.yaml-raw'].metadata.name),
}
