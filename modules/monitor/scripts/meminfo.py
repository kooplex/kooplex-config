import psutil, os, sys
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


def pprint_ntuple(nt):
    for name in nt._fields:
        value = getattr(nt, name)
        if name != 'percent':
            value = bytes2human(value)
        print('%-10s : %7s' % (name.capitalize(), value))

T=time.time()        
Fmemory_name="/usr/local/apache2/htdocs/memory.dat"
#Fmemory_name="/tmp/memory.dat"
Fswapmemory_name="/usr/local/apache2/htdocs/swapmemory.dat"
#Fswapmemory_name="/tmp/swapmemory.dat"
if int(sys.argv[1])%10==0:
    with open(Fmemory_name, "a") as F:
        if os.lstat(Fmemory_name).st_size==0:
            F.write("Time Total Available Percent Used Free Active Inactive Buffers Cached Shared\n")
        mem = psutil.virtual_memory()
        F.write("%f "%T)
        for name in mem._fields:
            value = getattr(mem, name)
            F.write("%f "%value)
        F.write("\n")
    with open(Fswapmemory_name, "a") as F:
        if os.lstat(Fswapmemory_name).st_size==0:
            F.write("Time Total Used Free Percent Sin Sout\n")
        swapmem = psutil.swap_memory()
        F.write("%f "%T)
        for name in swapmem._fields:
            value = getattr(swapmem, name)
            F.write("%f "%value)
        F.write("\n")

