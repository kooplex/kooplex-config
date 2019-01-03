import sys
import os
import psutil as ps
import numpy as np
import time


def bytes2human(n):
    # http://code.activestate.com/recipes/578019
    # >>> bytes2human(10000)
    # '9.8K'
    # >>> bytes2human(100001221)
    # '95.4M'
    symbols = ('K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y')
    prefix = {}
    for i, s in enumerate(symbols):
        prefix[s] = 1 << (i + 1) * 10
    for s in reversed(symbols):
        if n >= prefix[s]:
            value = float(n) / prefix[s]
            return '%.1f%s' % (value, s)
    return "%sB" % n


#templ = "%f %-17s %8s %8s %8s %5s%% %9s  %s\n"
templ = "%f %-17s %d %d %d %4.1f %9s  %s\n"
#with open("/tmp/disk.dat", "a") as F:
Fname="/usr/local/apache2/htdocs/disks.dat"

if int(sys.argv[1])%60==0:
    with open(Fname, "a") as F:
        if os.lstat(Fname).st_size==0:
            F.write("Time Device Total Used Free Use Type Mount\n")
    #print(templ % ("Device", "Total", "Used", "Free", "Use ", "Type", "Mount"))
 
        T=time.time()
        for part in ps.disk_partitions(all=False):
            if os.name == 'nt':
                if 'cdrom' in part.opts or part.fstype == '':
                    # skip cd-rom drives with no disk in it; they may raise
                    # ENOENT, pop-up a Windows GUI error for a non-ready
                    # partition or just hang.
                    continue
            usage = ps.disk_usage(part.mountpoint)
            #print(templ % (part.device,bytes2human(usage.total),
            #    bytes2human(usage.used),bytes2human(usage.free),int(usage.percent),
            #    part.fstype,part.mountpoint))
            F.write(templ %(T, part.device, usage.total, usage.used, usage.free, usage.percent, part.fstype, part.mountpoint))
        

