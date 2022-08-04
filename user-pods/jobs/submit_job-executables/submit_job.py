####!/opt/conda/envs/siesta//bin/python
# -*- coding: utf-8 -*-
"""
@summary: launch a kubernetes job
@authors: József Stéger
          Dávid Visontai
"""

import argparse
import logging
from kubernetes import client, config
from kubernetes.client import *
from pprint import pprint
import json

import os, pwd  

if __name__ == '__main__':
    logger = logging.getLogger(__name__)

    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--name", action = "store", required = True,
                    help = "The name of the job")
    parser.add_argument("-i", "--image", action = "store", required = True,
                    help = "Image name (need be present in `image-registry.vo.elte.hu`")
    parser.add_argument("-p", "--cpu", action = "store", type = int, default = 1,
                    help = "The request and limit of CPU cores")
    parser.add_argument("-m", "--memory", action = "store", default = "2G",
                    help = "The request and limit of memory")
    parser.add_argument("-g", "--gpu", action = "store", type = int, default = 0,
                    help = "The request and limit of GPUs")
    parser.add_argument("-c", "--command", action = "store", required = True,
                    help = "The entrypoint command of the job")
    parser.add_argument("--parallelism", action = "store", type = int, default = 1,
                    help = "Parallelism")
    parser.add_argument("--completions", action = "store", type = int, default = 1,
                    help = "Completion")
    parser.add_argument("-S", "--scratch", action = "store_true",
                    help = "Whether to mount the scratch volume")
    parser.add_argument("-H", "--home", action = "store_true",
                    help = "Whether to mount the home volume")
    parser.add_argument("-V", "--volumes", action = "store", nargs = '*',
                    help = "Which volumes to mount")
    parser.add_argument("-P", "--projects", action = "store", nargs = '*',
                    help = "Which projects to mount")
    parser.add_argument("-A", "--attachments", action = "store", nargs = '*',
                    help = "Which attachments to mount")
    #parser.add_argument("-t", "--namespace", action = "store", required = True,
    #                help = "The target namespace, wher the job is to run")
    #parser.add_argument("-u", "--user", action = "store", required = True,
    #                help = "Who runs")
    userinfo = pwd.getpwuid(os.getuid())
    username = userinfo.pw_name 
    namespace = os.getenv("NS_JOBS")

    args = parser.parse_args()

    # Get Current working directory
    PWD=os.getcwd()
    if args.command[0]=="/":
        command = args.command
    else:
        command = os.path.join(PWD, args.command)

    env_variables = [
        { "name": "LANG", "value": "en_US.UTF-8" },
        { "name": "USER", "value": username },
#        { "name": "", "value": "" },
    ]
    volume_mounts = [
            V1VolumeMount(name="nslcd", mount_path='/etc/mnt'),
#            {"name":"nslcd", "mountPath":'/etc/mnt'}, 
            V1VolumeMount(name="initscripts", mount_path="/init")
            #{"name":"initscripts", "mountPath":"/init"}
            ]
    volumes = [V1Volume(name="nslcd", config_map=V1ConfigMapVolumeSource(name="nslcd", default_mode=420, items=[
            V1KeyToPath(key="nslcd", path='nslcd.conf')])),
            V1Volume(name="initscripts", config_map=V1ConfigMapVolumeSource(name="initscripts", default_mode=0o777, items=[
            V1KeyToPath(key="nslcd",path="initscripts")]))
            ]


    if args.home:
        volume_mounts.append(
        V1VolumeMount(name="home", mount_path= f'/v/{username}', sub_path=username))
        volumes.append(V1Volume(name="home",persistent_volume_claim = V1PersistentVolumeClaimVolumeSource(claim_name= "home", read_only=True)))

    if args.scratch:
        volume_mounts.append(
        V1VolumeMount(name="scratch", mount_path= f'/v/scratch/', sub_path=username))
        
        volumes.append(V1Volume(name="scratch",persistent_volume_claim = V1PersistentVolumeClaimVolumeSource(claim_name= "scratch")))

    if args.projects:
        for p in args.projects:
            mnt_p = True
            volume_mounts.append({
                "name": "project",
                "mountPath": f'/v/projects/{p}',
                "subPath": f'projects/{p}',
            })
        volumes.append(V1Volume(name="project",persistent_volume_claim = V1PersistentVolumeClaimVolumeSource(claim_name= "project", read_only=False)))

    if args.attachments:
        for a in args.attachments:
            mnt_a = True
            volume_mounts.append({
                "name": "attachment",
                "mountPath": f'/v/attachments/{a}',
                "subPath": f'{a}',
            })
        volumes.append(V1Volume(name="attachment",persistent_volume_claim = V1PersistentVolumeClaimVolumeSource(claim_name= "attachment", read_only=True)))

    if args.volumes:
        for v in args.volumes:
            mnt_v = True
            volume_mounts.append({
                "name": f"v-{v}",
                "mountPath": f'/v/volumes/{v}',
            })
        volumes.append(V1Volume(name=f"v-{v}",persistent_volume_claim = V1PersistentVolumeClaimVolumeSource(claim_name= v, read_only=True)))

    resources = V1ResourceRequirements(limits={
                            "nvidia.com/gpu": args.gpu,
                            "cpu": args.cpu,
                            "memory": args.memory,
                            },
                        requests={
                            "nvidia.com/gpu": args.gpu,
                            "cpu": args.cpu,
                            "memory": args.memory,
                            }
                        )

    meta = V1ObjectMeta(name = args.name, namespace = namespace, labels = {"krftjobs":"true"})

    template = V1PodTemplateSpec()
    template.spec = V1PodSpec(containers=[
           #V1Container(name=args.name, image=args.image, command=[ "/bin/bash", "-c", args.command ], 
           V1Container(name=args.name, image=args.image, command=["/bin/bash", "-c", f"/init/initscripts; su  {username} -c {command}" ], 
                volume_mounts=volume_mounts, image_pull_policy="IfNotPresent", env=env_variables,
                resources=resources)
        ], restart_policy="OnFailure", volumes=volumes, node_name="veo2")
    spec = V1JobSpec(template=template)

    config.load_kube_config()
    v1 = BatchV1Api()

    data = V1Job(api_version = 'batch/v1', kind = 'Job', metadata = meta, spec = spec)

    try:
        #api_resp = v1.create_namespaced_job(namespace = args.namespace, body = job_definition)
        api_resp = v1.create_namespaced_job(namespace = namespace, body = data)
        #pprint(api_resp)
        print("Job submitted successfully job id: ")
    except rest.ApiException as e:
        logger.warning(e)
        if json.loads(e.body)['code'] != 409: # already exists
            logger.debug(job_definition)
            #pprint(job_definition)
            raise

