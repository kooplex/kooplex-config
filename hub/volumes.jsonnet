local Config = import '../config.libsonnet';


{
  'pv_service.yaml-raw': Config.PV(name=Config.volumes.service, cap='1G', path=Config.volumes.servicePath),
  'pvc_service.yaml-raw': Config.PVC(name='service', pvname=$['pv_service.yaml-raw'].metadata.name, cap=$['pv_service.yaml-raw'].spec.capacity.storage),

  'pv_garbage.yaml-raw': Config.PV(name=Config.volumes.garbage, cap='100G', path=Config.volumes.garbagePath),
  'pvc_garbage.yaml-raw': Config.PVC(name='garbage', pvname=$['pv_garbage.yaml-raw'].metadata.name, cap=$['pv_garbage.yaml-raw'].spec.capacity.storage),

  'pv_home.yaml-raw': Config.PV(name=Config.volumes.home, cap='100G', path=Config.volumes.homePath),
  'pvc_home.yaml-raw': Config.PVC(name='home', pvname=$['pv_home.yaml-raw'].metadata.name, cap=$['pv_home.yaml-raw'].spec.capacity.storage),

  'pv_project.yaml-raw': Config.PV(name=Config.volumes.project, cap='100G', path=Config.volumes.projectPath),
  'pvc_project.yaml-raw': Config.PVC(name='project', pvname=$['pv_project.yaml-raw'].metadata.name, cap=$['pv_project.yaml-raw'].spec.capacity.storage),

  'pv_report.yaml-raw': Config.PV(name=Config.volumes.report, cap='100G', path=Config.volumes.reportPath),
  'pvc_report.yaml-raw': Config.PVC(name='report', pvname=$['pv_report.yaml-raw'].metadata.name, cap=$['pv_report.yaml-raw'].spec.capacity.storage),

  'pv_edu.yaml-raw': Config.PV(name=Config.volumes.edu, cap='100G', path=Config.volumes.eduPath),
  'pvc_edu.yaml-raw': Config.PVC(name='edu', pvname=$['pv_edu.yaml-raw'].metadata.name, cap=$['pv_edu.yaml-raw'].spec.capacity.storage),

  'pv_attachment.yaml-raw': Config.PV(name=Config.volumes.attachment, cap='100G', path=Config.volumes.attachmentPath),
  'pvc_attachment.yaml-raw': Config.PVC(name='attachment', pvname=$['pv_attachment.yaml-raw'].metadata.name, cap=$['pv_attachment.yaml-raw'].spec.capacity.storage),

  'pv_scratch.yaml-raw': Config.PV(name=Config.volumes.scratch, cap='100G', path=Config.volumes.scratchPath),
  'pvc_scratch.yaml-raw': Config.PVC(name='scratch', pvname=$['pv_scratch.yaml-raw'].metadata.name, cap=$['pv_scratch.yaml-raw'].spec.capacity.storage),
}
