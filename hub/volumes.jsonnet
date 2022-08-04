local Config = import '../config.libsonnet';


{
  'pv_hub.yaml-raw': Config.PV(name=Config.ns + '-hub', cap='1G', path=Config.nfsvol + '/service/hub'),
  'pvc_hub.yaml-raw': Config.PVC(name='hub', pvname=$['pv_hub.yaml-raw'].metadata.name, cap=$['pv_hub.yaml-raw'].spec.capacity.storage),

  'pv_garbage.yaml-raw': Config.PV(name='garbage-k8plex-test', cap='100G', path=Config.nfsvol + '/garbage'),
  'pvc_garbage.yaml-raw': Config.PVC(name='garbage', pvname=$['pv_garbage.yaml-raw'].metadata.name, cap=$['pv_garbage.yaml-raw'].spec.capacity.storage),

  'pv_home.yaml-raw': Config.PV(name='home-k8plex-test', cap='100G', path=Config.nfsvol + '/home'),
  'pvc_home.yaml-raw': Config.PVC(name='home', pvname=$['pv_home.yaml-raw'].metadata.name, cap=$['pv_home.yaml-raw'].spec.capacity.storage),

  'pv_project.yaml-raw': Config.PV(name=Config.ns + '-project', cap='100G', path=Config.nfsvol + '/projects'),
  'pvc_project.yaml-raw': Config.PVC(name='project', pvname=$['pv_project.yaml-raw'].metadata.name, cap=$['pv_project.yaml-raw'].spec.capacity.storage),

  'pv_report.yaml-raw': Config.PV(name=Config.ns + '-report', cap='100G', path=Config.nfsvol + '/reports'),
  'pvc_report.yaml-raw': Config.PVC(name='report', pvname=$['pv_report.yaml-raw'].metadata.name, cap=$['pv_report.yaml-raw'].spec.capacity.storage),

  'pv_edu.yaml-raw': Config.PV(name=Config.ns + '-edu', cap='100G', path=Config.nfsvol + '/edu'),
  'pvc_edu.yaml-raw': Config.PVC(name='edu', pvname=$['pv_edu.yaml-raw'].metadata.name, cap=$['pv_edu.yaml-raw'].spec.capacity.storage),

  'pv_scratch.yaml-raw': Config.PV(name=Config.ns + '-scratch', cap='100G', path=Config.nfsvol + '/scratch'),
  'pvc_scratch.yaml-raw': Config.PVC(name='scratch', pvname=$['pv_scratch.yaml-raw'].metadata.name, cap=$['pv_scratch.yaml-raw'].spec.capacity.storage),
}
