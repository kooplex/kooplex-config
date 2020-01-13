#!/usr/bin/env python

import os
import urllib
import urllib2
import pwd
import multiprocessing
import random
import time
import logging
import psutil

logger = logging.getLogger(__name__)

def list_processes_by_name(process_name, username = None):
    pnl = process_name.lower()
    for p in psutil.process_iter():
        pd = p.as_dict(attrs = ['username', 'status', 'cmdline', 'name', 'pid'])
        if pnl in pd['name'].lower():
            if username is None:
                yield pd
            elif pd['username'] == username:
                yield pd

def lookupuid(username):
    return pwd.getpwnam(username).pw_uid

def randstring(size):
    random.seed(time.time())
    s = ''
    while len(s) < size:
        s += '%x' % random.randint(0, 255)
    return s[:size]

def urlopen(url, data = None, headers = None):
    if data:
        data = urllib.urlencode(data)
    headers = headers or {}
    req = urllib2.Request(url, data = data, headers = headers)
    resp = urllib2.urlopen(req)
    return resp.read()

def sudo(F):
    def wrapper(*args, **kwargs):
        username = args[0]
        uid = lookupuid(username)
        logger.info('sudo {} ({}) calls {}({}, {})'.format(username, uid, F, args, kwargs))
        q = multiprocessing.Queue()
        def worker():
            logger.debug('thread started, changing uid {}'.format(uid))
            os.setgid(1000)
            os.setuid(uid)
            try:
                result = F(*args, **kwargs)
                q.put_nowait((0, result))
                logger.debug('executed {}'.format(F))
            except Exception as e:
                logger.warn('executed {} -- exception {}'.format(F, e))
                q.put_nowait((1, e))
            logger.debug("thread ended")
        p = multiprocessing.Process(target = worker)
        p.start()
        p.join()
        status, result = q.get_nowait()
        if status != 0:
            raise result
        return result
    return wrapper

