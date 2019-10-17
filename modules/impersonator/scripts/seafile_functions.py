#!/usr/bin/env python

import os
import subprocess
import logging
import json
import seafile
import pwd

from common import randstring, sudo, urlopen

# initialization
logger = logging.getLogger(__name__)

###########################################
# seafile daemon manipulation
###########################################
class mySeafile:
    D_PARENT = '/mnt/.volumes/seafile'
    URL = 'http://kooplex-test-seafile/seafile' # FIXME: os.getenv()
    BASE_URL = 'http://kooplex-test-seafile' # FIXME: os.getenv()

    def __init__(self, username): 
        self._u = username
        self._mkdir(self.seaf_conf_dir)
        self._mkdir(self.seaf_log_dir)
        self._mkdir(self.seaf_path)
        self._mkdir(self.seaf_data_dir)
        with open(self.seaf_ini, 'w') as fp:
            fp.write(self.seaf_data_dir)
            logger.debug('updated file {}'.format(self.seaf_ini))
        self._devid = None

    def _mkdir(self, f):
        if os.path.exists(f): 
            assert os.path.isdir(f), "{} is not a folder".format(f)
            return
        os.mkdir(f)
        logger.debug('mkdir {}'.format(f))

    @property
    def seaf_conf_dir(self): return os.path.join(self.D_PARENT, self._u, 'seafconf')
    @property
    def seaf_log_dir(self): return os.path.join(self.D_PARENT, self._u, 'seafconf/logs')
    @property
    def seaf_path(self): return os.path.join(self.D_PARENT, self._u, 'synchron')
    @property
    def seaf_data_dir(self): return os.path.join(self.D_PARENT, self._u, 'seafile-data')

    @property
    def seaf_ini(self): return os.path.join(self.D_PARENT, self._u, 'seafconf/seafile.ini')
    @property
    def seaf_sock(self): return os.path.join(self.D_PARENT, self._u, 'seafile-data/seafile.sock')
    @property
    def seaf_idfile(self): return os.path.join(self.D_PARENT, self._u, 'seafile-data/id')
    @property
    def seaf_ccnet_conf(self): return os.path.join(self.D_PARENT, self._u, 'seafile-data/ccnet.conf')

    @property
    def client(self):
        return seafile.RpcClient(self.seaf_sock)

    def start(self):
        try:
            self.clone_tasks()
            logger.debug('daemon for {} already running'.format(self._u))
            return
        except Exception as e:
            pass
        cmd = [ "seaf-daemon", "--daemon", "-c", self.seaf_conf_dir, "-d", self.seaf_data_dir, "-w", self.seaf_path ]
        proc = subprocess.Popen(cmd, env = dict(os.environ))
        logger.info('starting daemon for {} -- {}'.format(self._u, cmd))
        proc_ret = proc.wait()
        logger.info('process response: {}'.format(proc_ret))
        return proc_ret

    def seaf_stop(self):
        self.client.shutdown()

    @property
    def device_id(self):
        if self._devid:
            return self._devid
        if os.path.exists(self.seaf_idfile):
            with open(self.seaf_idfile, 'r') as fp:
                self._devid = fp.read().strip()
            return self._devid
        if os.path.exists(self.seaf_ccnet_conf):
            with open(self.seaf_ccnet_conf, 'r') as fp:
                for line in fp:
                    m = re.search('ID = (.*)', line)
                    if m:
                        self._devid = m.group(1)
                        logger.debug('Migrating device id from ccnet conf')
                        break
        if not self._devid:
            logger.debug('New device id created')
            self._devid = randstring(40)
        with open(self.seaf_idfile, 'w') as fp:
            fp.write(self._devid)
        return self._devid

    def clone_tasks(self):
        return self.client.get_clone_tasks()

    def get_token(self, password, tfa = None):
        platform = 'linux'
        device_id = self.device_id
        device_name = 'terminal-' + os.uname()[1]
        client_version = ''
        platform_version = ''
        data = {
            'username': self._u,
            'password': password,
            'platform': platform,
            'device_id': device_id,
            'device_name': device_name,
            'client_version': client_version,
            'platform_version': platform_version,
        }
        if tfa:
            headers = { 'X-SEAFILE-OTP': tfa, }
        else:
            headers = None
        token_json = urlopen("{}/api2/auth-token/".format(self.URL), data = data, headers = headers)
        logger.debug('token for {} retrieved'.format(self._u))
        return json.loads(token_json)['token']

    def get_repo_download_info(self, url, token): #FIXME: rename function
        headers = { 'Authorization': 'Token %s' % token }
        repo_info = urlopen(url, headers = headers)
        return json.loads(repo_info)

    def sync(self, password, libraryid, librarypassword):
        token = self.get_token(password)
        tmp = self.get_repo_download_info("{}/api2/repos/{}/download-info/".format(self.URL, libraryid), token)
        folder = os.path.join(self.seaf_path, tmp['repo_name'])
        self._mkdir(folder)
        encrypted = tmp['encrypted']
        magic = tmp.get('magic', None)
        enc_version = tmp.get('enc_version', None)
        random_key = tmp.get('random_key', None)
        clone_token = tmp['token']
        relay_id = tmp['relay_id']
        relay_addr = tmp['relay_addr']
        relay_port = str(tmp['relay_port'])
        email = tmp['email']
        repo_name = tmp['repo_name']
        version = tmp.get('repo_version', 0)
        repo_salt =  tmp['salt']
        is_readonly = None
        if 'permission' in tmp.keys():
            is_readonly = tmp['permission']
        more_info = None
        more_info_dict = {'server_url': self.BASE_URL }
        if repo_salt:
            more_info_dict.update({'repo_salt': repo_salt})
        if is_readonly:
            more_info_dict.update({'is_readonly': is_readonly})
        if more_info_dict:
            more_info = json.dumps(more_info_dict)
        if encrypted == 1:
            repo_passwd = librarypassword
        else:
            repo_passwd = None
        self.client.clone(libraryid,
                          version,
                          relay_id,
                          repo_name.encode('utf-8'),
                          folder,
                          clone_token,
                          repo_passwd, magic,
                          relay_addr,
                          relay_port,
                          email, random_key, enc_version, more_info)
        logger.info('Synchronizing {} for {}'.format(folder, self._u))
        if folder.startswith(self.D_PARENT):
            folder = folder[(len(self.D_PARENT) + 1):]
        return folder

    def desync(self, libraryid):
        self.client.remove_repo(libraryid)
        return "OK" #FIXME: return folder



#def seaf_listremote(username, password):
#    url = 'http://kooplex-test-seafile/seafile'
#    fs = FS(username)
#    seafile_rpc = seafile.RpcClient(fs.seaf_sock)
#    username__ = "j@https://kooplex-test.elte.hu/hydra" #FIXME
#    token = get_token(url, username__, password, None, fs)
#    return get_repo_download_info("%s/api2/repos/" % (url), token)
#
#
#def seaf_listlocal(username):
#    fs = FS(username)
#    seafile_rpc = seafile.RpcClient(fs.seaf_sock)
#    return seafile_rpc.get_repo_list(-1, -1)







def mkdir_parent(username):
    f = os.path.join(mySeafile.D_PARENT, username)
    U = pwd.getpwnam(username)
    if not os.path.exists(f):
        os.mkdir(f)
        os.chown(f, U.pw_uid, U.pw_gid)
        logger.info('Created {}'.format(f))


@sudo
def start_sync(username, password, libraryid, librarypassword):
    sfo = mySeafile(username)
    sfo.start()
    #FIXME: check if already syncing
    #for t in sfo.clone_tasks():
    #    print (t)
    #print ('vege')
    return sfo.sync(password, libraryid, librarypassword)

@sudo
def stop_sync(username, libraryid):
    sfo = mySeafile(username)
    sfo.start()
    sfo.desync(libraryid)
    #FIXME: stop sfo if doing nothing

