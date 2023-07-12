local Config = import '../config.libsonnet';

local jobns = Config.ns + '-jobs';

{
  //  'pv_garbage.yaml-raw': Config.PV(name=Config.volumes.garbage + '-jobs', cap='100G', path=Config.volumes.garbagePath),
  //  'pvc_garbage.yaml-raw': Config.PVC(name='garbage', ns=jobns, pvname=$['pv_garbage.yaml-raw'].metadata.name, cap=$['pv_garbage.yaml-raw'].spec.capacity.storage),

  'pv_home.yaml-raw': Config.PV(name=Config.volumes.home + '-jobs', cap='100G', path=Config.volumes.homePath),
  'pvc_home.yaml-raw': Config.PVC(name='home', ns=jobns, pvname=$['pv_home.yaml-raw'].metadata.name, cap=$['pv_home.yaml-raw'].spec.capacity.storage),

  'pv_project.yaml-raw': Config.PV(name=Config.volumes.project + '-jobs', cap='100G', path=Config.volumes.projectPath),
  'pvc_project.yaml-raw': Config.PVC(name='project', ns=jobns, pvname=$['pv_project.yaml-raw'].metadata.name, cap=$['pv_project.yaml-raw'].spec.capacity.storage),

  //  'pv_report.yaml-raw': Config.PV(name=Config.volumes.report + '-jobs', cap='100G', path=Config.volumes.reportPath),
  //  'pvc_report.yaml-raw': Config.PVC(name='report', ns=jobns, pvname=$['pv_report.yaml-raw'].metadata.name, cap=$['pv_report.yaml-raw'].spec.capacity.storage),

  //  'pv_edu.yaml-raw': Config.PV(name=Config.volumes.edu + '-jobs', cap='100G', path=Config.volumes.eduPath),
  //  'pvc_edu.yaml-raw': Config.PVC(name='edu', ns=jobns, pvname=$['pv_edu.yaml-raw'].metadata.name, cap=$['pv_edu.yaml-raw'].spec.capacity.storage),

  'pv_scratch.yaml-raw': Config.PV(name=Config.volumes.scratch + '-jobs', cap='100G', path=Config.volumes.scratchPath),
  'pvc_scratch.yaml-raw': Config.PVC(name='scratch', ns=jobns, pvname=$['pv_scratch.yaml-raw'].metadata.name, cap=$['pv_scratch.yaml-raw'].spec.capacity.storage),

  'pv_attachment.yaml-raw': Config.PV(name=Config.volumes.attachment, cap='100G', path=Config.volumes.attachmentPath),
  'pvc_attachment.yaml-raw': Config.PVC(name='attachments', ns=jobns, pvname=$['pv_attachment.yaml-raw'].metadata.name, cap=$['pv_attachment.yaml-raw'].spec.capacity.storage),
}
