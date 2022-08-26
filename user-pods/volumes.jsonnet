local Config = import '../config.libsonnet';


{
  'pv_hub.yaml-raw': Config.PV(name=Config.volumes.hub + '-pods', cap='1G', path=Config.volumes.hubPath),
  'pvc_hub.yaml-raw': Config.PVC(name='hub', ns=Config.ns + '-pods', pvname=$['pv_hub.yaml-raw'].metadata.name, cap=$['pv_hub.yaml-raw'].spec.capacity.storage),

  'pv_garbage.yaml-raw': Config.PV(name=Config.volumes.garbage + '-pods', cap='100G', path=Config.volumes.garbagePath),
  'pvc_garbage.yaml-raw': Config.PVC(name='garbage', ns=Config.ns + '-pods', pvname=$['pv_garbage.yaml-raw'].metadata.name, cap=$['pv_garbage.yaml-raw'].spec.capacity.storage),

  'pv_home.yaml-raw': Config.PV(name=Config.volumes.home + '-pods', cap='100G', path=Config.volumes.homePath),
  'pvc_home.yaml-raw': Config.PVC(name='home', ns=Config.ns + '-pods', pvname=$['pv_home.yaml-raw'].metadata.name, cap=$['pv_home.yaml-raw'].spec.capacity.storage),

  'pv_project.yaml-raw': Config.PV(name=Config.volumes.project + '-pods', cap='100G', path=Config.volumes.projectPath),
  'pvc_project.yaml-raw': Config.PVC(name='project', ns=Config.ns + '-pods', pvname=$['pv_project.yaml-raw'].metadata.name, cap=$['pv_project.yaml-raw'].spec.capacity.storage),

  'pv_report.yaml-raw': Config.PV(name=Config.volumes.report + '-pods', cap='100G', path=Config.volumes.reportPath),
  'pvc_report.yaml-raw': Config.PVC(name='report', ns=Config.ns + '-pods', pvname=$['pv_report.yaml-raw'].metadata.name, cap=$['pv_report.yaml-raw'].spec.capacity.storage),

  'pv_edu.yaml-raw': Config.PV(name=Config.volumes.edu + '-pods', cap='100G', path=Config.volumes.eduPath),
  'pvc_edu.yaml-raw': Config.PVC(name='edu', ns=Config.ns + '-pods', pvname=$['pv_edu.yaml-raw'].metadata.name, cap=$['pv_edu.yaml-raw'].spec.capacity.storage),

  'pv_scratch.yaml-raw': Config.PV(name=Config.volumes.scratch + '-pods', cap='100G', path=Config.volumes.scratchPath),
  'pvc_scratch.yaml-raw': Config.PVC(name='scratch', ns=Config.ns + '-pods', pvname=$['pv_scratch.yaml-raw'].metadata.name, cap=$['pv_scratch.yaml-raw'].spec.capacity.storage),
}
