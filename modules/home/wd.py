#! /usr/bin/python3
"""
Author: Jozsef Steger
Created: 23. May 2017.
Summary: watch a filesystem directory recursively for changes, 
         and when they happen with a limited rate issue synchronization 
         to the owncloud.
"""
import time
from watchdog.observers import Observer
from watchdog.events import RegexMatchingEventHandler
import subprocess
import re
import threading

class MySync():
    enabled = threading.Event()
    synced = threading.Event()
    alert = threading.Event()

    def __init__(self, command, syncwait = 10, stoppath = '.', debug = False):
        self.enabled.set()
        self.command = command
        self.syncwait = syncwait
        self.stoppath = stoppath
        self.debug = debug

    def register(self, e):
        if self.debug:
            print ("registered: %s %s" % (e.src_path, e.event_type))
        self.synced.clear()
        if e.event_type == 'deleted' and e.src_path == self.stoppath:
            if self.debug:
                self.alert.set()
                print ("%s removed, I won't sync to owncloud to avid dataloss" % self.stoppath)
        self.commit()

    def expired(self):
        if self.debug:
            print ("expired")
        self.enabled.set()
        if not self.synced.is_set():
            self.commit()

    def commit(self):
        if self.synced.is_set() or not self.enabled.is_set() or self.alert.is_set():
            return
        self.enabled.clear()
        if self.debug:
            print ("committing")
        subprocess.call(self.command)
        self.synced.set()
        t = threading.Timer(self.syncwait, self.expired)
        t.start()

class MyHandler(RegexMatchingEventHandler):
    ignore_regexes = [re.compile(r"^\."), re.compile(r"^.*/\.")]

    def process(self, event):
        sync.register(event)

    def on_modified(self, event):
        if not event.is_directory:
            self.process(event)

    def on_created(self, event):
        self.process(event)

    def on_deleted(self, event):
        self.process(event)

if __name__ == '__main__':
    from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
    from distutils.dir_util import mkpath

    parser = ArgumentParser(formatter_class = ArgumentDefaultsHelpFormatter)
    parser.add_argument("-d", "--debug", action = "store_true", dest = "debug", help = "whether to show what is going on")
    parser.add_argument("-S", "--verbose", action = "store_true", dest = "debugoc", help = "whether to show what is going on with the owncloudcmd")
    parser.add_argument("-c", "--cloud-url", action = "store", dest = "url", default = "https://compare.vo.elte.hu/owncloud", help = "owncloud API url")
    parser.add_argument("-w", "--sync-wait", action = "store", type = int, dest = "syncwait", default = 10, help = "wait some seconds between syncs to prevent the cloud API from flooding")
    parser.add_argument("-R", "--avoid-recursive", action = "store_false", dest = "recursive", help = "whether to avoid recursice check on folder")
    parser.add_argument("-i", "--ignore-pattern", nargs = "*", action = "store", dest = "ignore", help = "regular expressions of files to ignore", default = [r"^\.", r"^.*/\."])
    parser.add_argument("folder", nargs = 1, help = "which folder to watch")

    args = parser.parse_args()

    path = args.folder[0]
    mkpath(path, verbose = args.debug)
    command = [ "owncloudcmd", "-n", path, args.url ]
    if not args.debugoc:
#FIXME: ez nem jol van a owncloudcmd-ben implementalva...
        command.insert(1, '-s')
    if args.debug:
        print ("sync command: %s" % command)
    sync = MySync(command, syncwait = args.syncwait, stoppath = path, debug = args.debug)
    sync.commit()
    ignore_regexes = [ re.compile(r) for r in args.ignore ]
    observer = Observer()
    handler = MyHandler()
    handler.ignore_regexes = ignore_regexes
    observer.schedule(handler, recursive = args.recursive, path = path)
    observer.start()

    try:
        while True:
            time.sleep(1)
            if sync.alert.is_set():
                raise KeyboardInterrupt()
    except KeyboardInterrupt:
        observer.stop()
    finally:
        observer.join()