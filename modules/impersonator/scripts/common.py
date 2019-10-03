#!/usr/bin/env python

import os
import urllib
import urllib2
import pwd
import threading
import Queue as queue
import random
import time
import logging

logger = logging.getLogger(__name__)

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
        q = queue.Queue()
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
        t = threading.Thread(target = worker)
        t.start()
        t.join()
        status, result = q.get_nowait()
        if status != 0:
            raise result
        return result
    return wrapper

