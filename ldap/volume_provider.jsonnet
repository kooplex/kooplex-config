local Config = import '../config.libsonnet';

{
  'pv_ldapp.yaml-raw': Config.PV(name='ldap-test', cap='1G', path=Config.nfsvol + '/service/ldap'),
  'pvc_ldapp.yaml-raw': Config.PVC(name='ldap-data', pvname=$['pv_ldapp.yaml-raw'].metadata.name, cap=$['pv_ldapp.yaml-raw'].spec.capacity.storage),
}
