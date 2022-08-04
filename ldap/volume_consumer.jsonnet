local Config = import '../config.libsonnet';

{
  'pv_ldapc.yaml-raw': Config.PV(name='ldap-test-slave', cap='1G', path=Config.nfsvol + '/service/ldap-slave'),
  'pvc_ldapc.yaml-raw': Config.PVC(name='ldap-data-slave', pvname=$['pv_ldapc.yaml-raw'].metadata.name, cap=$['pv_ldapc.yaml-raw'].spec.capacity.storage),
}
