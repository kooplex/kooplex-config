import psutil as ps
import numpy as np
import time 

with open("/usr/local/apache2/htdocs/cpu.dat", "a") as F:
#with open("/tmp/cpu.dat", "a") as F:
    cpuperc = ps.cpu_percent(interval=10, percpu=True)
    F.write("{0}  ".format(time.time()))
    for C in range(ps.cpu_count()):
        F.write("{0} ".format(cpuperc[C]))
    F.write("\n")
        
