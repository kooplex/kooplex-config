#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
@summary: launch a kubernetes job
@authors: József Stéger
          Dávid Visontai
"""
import argparse
import logging
import json
import requests
import os, pwd, sys
import pandas
from pprint import pprint

with open('/.s/job_token') as f:
    api_token = f.read()

userinfo = pwd.getpwuid(os.getuid())
api_user = userinfo.pw_name
namespace = os.getenv("NS_JOBS")
server = os.getenv("SERVERNAME")
url_api = f'https://{server}/hub/api'


def _get(url):
    session = requests.Session()
    session.cookies.set('api_user', api_user)
    session.cookies.set('api_token', api_token)
    response = session.get(url)
    if response.status_code == 200:
        return response.json()
    raise Exception(f"Unexpected behaviour {response}")

def _post(url, data):
    session = requests.Session()
    session.cookies.set('api_user', api_user)
    session.cookies.set('api_token', api_token)
    response = session.post(url, data = data)
    if response.status_code == 200:
        return response.json()
    raise Exception(f"Unexpected behaviour {response}")

def _delete(url):
    session = requests.Session()
    session.cookies.set('api_user', api_user)
    session.cookies.set('api_token', api_token)
    response = session.delete(url)
    if response.status_code == 200:
        return response.json()
    raise Exception(f"Unexpected behaviour {response}")

def get_resources(resource):
    r = _get(f'{url_api}/{resource}/')
    return r

def delete_job(name):
    r = _delete(f'{url_api}/delete/{name}/')
    return r

def get_job(name):
    r = _get(f'{url_api}/info/{name}/')
    return r

def log_job(name):
    r = _get(f'{url_api}/log/{name}/')
    return r

def post_submit(args):
    i = get_resources('images')
    new_line = '\n\t'

    # check image existance
    assert args.image in i['images'], f"Please make sure you provide a valid image name{new_line}{new_line.join(i['images'])}"

    req = {
        'name': args.name,
        'namespace': namespace,
        'image': args.image,
        'cpu': args.cpu,
        'memory': args.memory,
        'gpu': args.gpu,
        'nodename': args.nodename,
        'scratch': args.scratch,
    }

    # Get Current working directory
    PWD = os.path.realpath(os.path.curdir)
    if args.command[0]=="/":
        command = args.command
    else:
        command = os.path.join(PWD, args.command)

    if args.wd:
        CWD = os.path.realpath(args.wd)
    else: 
        CWD = PWD
    req['command'] = f"cd {CWD}; su {api_user} -c {command}"

    # home? 
    if args.home_rw:
        req['home_rw'] = True
    if args.home_ro:
        req['home_rw'] = False
    if args.home_rw and args.home_ro:
        assert args.force, "You are trying to mount home as rw and ro at the same time"
        print ("WARNING", "Your home is to be mounted read only")
    

    # check volume existance
    v_ro = set()
    v_rw = set()
    if args.volumes_ro or args.volumes_rw:
        v = get_resources('volumes')
        folders = { r['folder']: r['id'] for r in v['volumes'] }
        folders.update({ r['folder']: r['id'] for r in v['attachments'] })
        v_ids = [ str(i) for i in folders.values() ]

        if args.volumes_ro:
            for v_ in args.volumes_ro:
                if v_ in folders:
                    v_ro.add(folders[v_])
                elif v_ in v_ids:
                    v_ro.add(int(v_))
                else:
                    assert args.force, f"Please make sure an existing volume is provided: {v_} is unknown.{new_line}{new_line.join(folders.keys())}"
                    print ("WARNING", f"Read only volume {v_} is unknown and skipped")
        if args.volumes_rw:
            for v_ in args.volumes_rw:
                if v_ in folders:
                    i = folders[v_]
                    if i in v_ro:
                        assert args.force, f"You are trying to mount: {v_} as both read only and read write"
                        print ("WARNING", f"Volume/attachment {v_} is to be mounted read only")
                    else:
                        v_rw.add(i)
                elif v_ in v_ids:
                    i = int(v_)
                    if i in v_ro:
                        assert args.force, f"You are trying to mount: {v_} as both read only and read write"
                        print ("WARNING", f"Volume/attachment {v_} is to be mounted read only")
                    else:
                        v_rw.add(i)
                else:
                    assert args.force, f"Please make sure an existing volume is provided: {v_} is unknown.{new_line}{new_line.join(folders.keys())}"
                    print ("WARNING", f"Read write volume {v_} is unknown and skipped")
        if v_ro:
            req['volumes_ro'] = list(v_ro)
        if v_rw:
            req['volumes_rw'] = list(v_rw)

    # check project existance
    p_ro = set()
    p_rw = set()
    if args.projects_ro or args.projects_rw:
        p = get_resources('projects')
        projects = { r['name']: r['id'] for r in p['projects'] }
        p_ids = [ str(i) for i in projects.values() ]

        if args.projects_ro:
            for p_ in args.projects_ro:
                if p_ in projects:
                    p_ro.add(projects[p_])
                elif p_ in p_ids:
                    p_ro.add(int(p_))
                else:
                    assert args.force, f"Please make sure an existing project is provided: {p_} is unknown.{new_line}{new_line.join(projects.keys())}"
                    print ("WARNING", f"Read only project {p_} is unknown and skipped")
        if args.projects_rw:
            for p_ in args.projects_rw:
                if p_ in projects:
                    i = projects[p_]
                    if i in p_ro:
                        assert args.force, f"You are trying to mount: {p_} as both read only and read write"
                        print ("WARNING", f"Project {p_} is to be mounted read only")
                    else:
                        p_rw.add(i)
                elif p_ in p_ids:
                    i = int(p_)
                    if i in p_ro:
                        assert args.force, f"You are trying to mount: {p_} as both read only and read write"
                        print ("WARNING", f"Project {p_} is to be mounted read only")
                    else:
                        p_rw.add(i)
                else:
                    assert args.force, f"Please make sure an existing project is provided: {p_} is unknown.{new_line}{new_line.join(projects.keys())}"
                    print ("WARNING", f"Read write project {p_} is unknown and skipped")
        if p_ro:
            req['projects_ro'] = list(p_ro)
        if p_rw:
            req['projects_rw'] = list(p_rw)

    return _post(f'{url_api}/submit/{args.name}/', { 'job_description': json.dumps(req) })


## Validators
def memory_type(value):
    if "M" in value or "G" in value:
        pass;
    else:
        raise argparse.ArgumentTypeError("The format for memory request ( -m ) should be '100M' or '24G'")
    return value


if __name__ == '__main__':
    logger = logging.getLogger(__name__)
#    sys.tracebacklimit = 0

    parser = argparse.ArgumentParser()

    sub_parsers = parser.add_subparsers(title='command', required = True)

    parser_list = sub_parsers.add_parser('list', help='retrieve the list of various job resources')
    parser_list.add_argument('resource', 
        help='select one of the resource types',
        choices = ['images', 'projects', 'volumes', 'nodes', 'jobs'],
    )

    parser_submit = sub_parsers.add_parser('submit', help='configure and submit your job')
    parser_submit.add_argument("-n", "--name", action = "store", required = True,
        help = "The name of the job")
    parser_submit.add_argument("-i", "--image", action = "store", required = True,
        help = "Image name (need be present in `image-registry.vo.elte.hu`)")
    parser_submit.add_argument("--cpu", action = "store", type = int, default = 1,
        help = "The request and limit of CPU cores")
    parser_submit.add_argument("-m", "--memory", action = "store", default = "2G",
        help = "The request and limit of memory e.g. '-m 16G'", type=memory_type)
    parser_submit.add_argument("--gpu", action = "store", type = int, default = 0,
        help = "The request and limit of GPUs")
    parser_submit.add_argument("--wd", action = "store", default="./",
        help = "Path of the working directory")
    parser_submit.add_argument("-c", "--command", action = "store", required = True,
        help = "The entrypoint command of the job")
    parser_submit.add_argument("--parallelism", action = "store", type = int, default = 1,
        help = "Parallelism")
    parser_submit.add_argument("--completions", action = "store", type = int, default = 1,
        help = "The environmental variable JOB_COMPLETION_INDEX will loop from 0 to this number")
    parser_submit.add_argument("-S", "--scratch", action = "store_true",
        help = "Whether to mount the scratch volume")
    parser_submit.add_argument("--home_ro", action = "store_true",
        help = "Whether to mount the home volume")
    parser_submit.add_argument("--home_rw", action = "store_true",
        help = "Whether to mount home read-only")
    parser_submit.add_argument("-v", "--volumes_ro", action = "store", nargs = '*',
        help = "Which volumes or attachments to mount in read only")
    parser_submit.add_argument("-V", "--volumes_rw", action = "store", nargs = '*',
        help = "Which volumes or attachments to mount in read write")
    parser_submit.add_argument("-p", "--projects_ro", action = "store", nargs = '*',
        help = "Which project folders to mount as read only")
    parser_submit.add_argument("-P", "--projects_rw", action = "store", nargs = '*',
        help = "Which project folders to mount read write")
    parser_submit.add_argument("--nodename", action = "store", default = "",
        help = "Which server to use")
    parser_submit.add_argument("-f", "--force", action = "store_true",
        help = "Whether try to autocorrect mistakes and submit job anyways")
#    parser_submit.add_argument("--nodeselector", action = "store", default = "default",
#        help = "Which server to use by label (DEFAULT: default)")

    parser_log = sub_parsers.add_parser('log', help='get the log of your job')
    parser_log.add_argument("-n", "--name", action = "store", required = True,
        help = "The name of the job")
    
    parser_info = sub_parsers.add_parser('info', help='get some information about your job(s)')
    parser_info.add_argument("-n", "--name", action = "store", required = True,
        help = "The name of the job")
    
    parser_kill = sub_parsers.add_parser('kill', help='kill and/or delete your job(s)')
    parser_kill.add_argument("-n", "--name", action = "store", required = True,
        help = "The name of the job")
    
    args = parser.parse_args()
    command = sys.argv[1]

    if command == 'list':
        r = get_resources(args.resource)
        if args.resource == 'nodes':
            df = pandas.DataFrame(r['resources'])
            print(df[['node_name', 'avail_cpu', 'total_cpu', 'avail_gpu', 'avail_memory', 'total_gpu', 'total_memory']]) #.to_csv(index=False, sep="\t"))
        elif args.resource == 'jobs':
            d = pandas.DataFrame(r['jobs'])
            if not d.empty:
                mkint = lambda x: x if x else 0
                for a in ['active', 'ready','failed']:
                   d[a] = d.status.apply(lambda x: mkint(x[a]))
                d.rename(columns={'name':'jobs'}, inplace=True)
                d.drop(columns=['status'], inplace=True)
                print(d.to_csv(index=False, sep="\t"))
            else:
                print("You have no jobs")
        elif args.resource == 'images':
            # FIXME description?
            print("List of available images")
            print("\n".join(r['images']))
        elif args.resource == 'projects':
            # FIXME description?
            print("List of available projects")
            for p in r['projects']:
                print(f"{p['id']}\t{p['name']}")
            else:
                print("You have no projects.")
        elif args.resource == 'volumes':
            if len(r['volumes']) + len(r['attachments']) == 0:
                print("There are no volumes and/or attachments you can mount.")
            else:
                # FIXME description?
                print("List of available volumes")
                for p in r['volumes']:
                    print(f"{p['id']}\tvolume\t{p['folder']}")
                for p in r['attachments']:
                    print(f"{p['id']}\tattachment\t{p['folder']}")
        else:
            print(r)
    elif command == 'submit':
        r = post_submit(args)
        if "Error" in r:
            print(f"Error:\t{r['message']}")
        else:
            print(f"Created:\t {r['created']}")
            import os, time
            logdir = os.path.join(os.getenv("HOME","/tmp/"),".jobslog")
            try:
                os.mkdir(logdir)
            except:
                pass
            logfile = os.path.join(logdir, f"jobs_desc_{time.time()}")
            with open(logfile, 'w') as f:
                f.write(str(r))
    elif command == 'info':
        r = get_job(args.name)
        if 'pod_condition_messages' in r:
            if r['pod_condition_messages']:
                pcm = "\n  * " + "\n  * ".join(r['pod_condition_messages'])
                print(f"Pod Condition Messages: {pcm}")
            print("Status: ")
            for k,v in r['status'].items(): 
                if k=="uncounted_terminated_pods":
                    continue
                if v:
                    print(f"  * {k}: {v}")
        else:
            print(f"You have no job named {args.name}.")
    elif command == 'kill':
        r = delete_job(args.name)
        if "Error" in r:
            print(f"Error:\t{r['message']}")
        else:
            print(f"{r['response']}. Your job {args.name} is scheduled to be terminated.")
    elif command == 'log':
        r = log_job(args.name)
        for i,l in enumerate(r['container_logs']):
            print(l)
            if i<len(r['container_logs'])-1:
                print("* "*32)
        else:
            print(f"You have no job named {args.name}.")
    else:
        print (command)
        print (args)
        print (dir(args))
