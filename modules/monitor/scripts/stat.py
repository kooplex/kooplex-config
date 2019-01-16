import docker
import psycopg2
from numpy import *
import datetime

def insert_item(table, col_name, value):
    sqlc = "INSERT INTO %s (%s) VALUES ('%s');" % (table, col_name, value)
    cur.execute(sqlc)
    conn.commit()

def update_item(table, col_name, value, exist_col_name, exist_value):
    sqlc = "UPDATE %s SET %s = '%s' WHERE %s = '%s';" % (table, col_name, value, exist_col_name, exist_value)
    #print(sqlc)
    cur.execute(sqlc)
    conn.commit()

def get_item(table, col_name, value):
    sqlc = "select * from %s where %s ='%s';" % (table, col_name, value)
    cur.execute(sqlc)
    res = cur.fetchone()
    conn.commit()
    return res

def get_project_name(container):
    for i in container.attrs['Config']['Env']:
        if "PR_NAME" in i:
            return i.split('=')[1]

def get_user_name(container):
    for i in container.attrs['Config']['Env']:
        if "NB_USER" in i:
            return i.split('=')[1]

def check_last_changed(table_name,  container_id, col_name, value, threshold, s_type):
    sqlc = "select * from %s where container_id = %d \
      order by last_read desc limit 1;" % (table_name, container_id)
    cur.execute(sqlc)
    res = cur.fetchone()
    if res:
        for icol, name in enumerate(cur.description):
            if name[0] == col_name:
                #print(hubuser_id, container_id, col_name[0], res[icol], cols[col_name[0]], abs(cols[col_name[0]] - res[icol])/change[col_name[0]])
                if ( res[icol] == 0 ) or ( s_type == 'c' and value > threshold ) or\
                        ( s_type == 'a' and abs(value - res[icol]) > threshold ):
                    #print('Ins', col_name, hubuser_id, container_id, value, threshold, abs(value - res[icol]))
                    #print()
                    return True
    else:
        return True

    return False

def insert_new_row(table_name, container_id, col_name, value):
    sqlc = "INSERT INTO %s ( container_id, %s) VALUES (%d, %s);" % \
           (table_name, col_name, container_id, value)
    #print(sqlc)
    res = cur.execute(sqlc)
    conn.commit()

T0 = datetime.datetime.now()

conn = psycopg2.connect("dbname=monitor user=postgres")
cur = conn.cursor()

client = docker.from_env()
container_list = client.containers.list()

T1 = datetime.datetime.now()
print((T1-T0).total_seconds())

#Check for stopped containers
sqlc = "select * from container;"
cur.execute(sqlc)
res = cur.fetchall()
conn.commit()
col_id = 0
for i, e in enumerate(cur.description):
    if e[0] == 'container_name':
        col_id = i

running_conts = [ r[col_id] for r in res ]
for cont in container_list:
    if cont.attrs['Name'] in running_conts:
        running_conts.remove(cont.attrs['Name'])

for r in running_conts:
   update_item('container','running',"f", 'container_name', r)

T2 = datetime.datetime.now()
print((T2-T0).total_seconds())

for ic, cont in enumerate(container_list):
    #Get container name
    container_name = cont.attrs['Name']

#    if container_name.split("-")[0] == '/nb':
    if 1==1:
        #Query for project, if it does not exist then insert it
        project_name = get_project_name(cont)

        res = get_item('project', 'project', project_name)
        if not res:
            insert_item('project', 'project', project_name)
            res = get_item('project', 'project', project_name)
        project_id = res[0]

        #Query for hubuser, if it does not exist then insert it
        username = get_user_name(cont)

        res = get_item('hubuser', 'username', username)
        if not res:
            insert_item('hubuser', 'username', username)
            res = get_item('hubuser', 'username', username)
        hubuser_id = res[0]

        #Query for container_name, if it does not exist then insert it
        res = get_item('container', 'container_name', container_name)
        if res:
            update_item('container','running',"t", 'container_name', container_name,)
        if not res:
            insert_item('container', 'project_id, container_name, hubuser', "%d', '%s', '%d"%(project_id, container_name, hubuser_id))
            res = get_item('container', 'container_name', container_name)
        container_id = res[0]





        #Get statistics from container
        T = datetime.datetime.now()
        print((T-T0).total_seconds())
        stat = cont.stats(stream=False)

        memoryusage = stat['memory_stats']['usage']
        #percpu = array(stat['cpu_stats']['cpu_usage']['percpu_usage'])-array(stat['precpu_stats']['cpu_usage']['percpu_usage'])
        #print("Usage per cpu for %s :"%container_name, percpu, percpu.mean())

        # This is after https://github.com/moby/moby/blob/eb131c5383db8cac633919f82abad86c99bffbe5/cli/command/container/stats_helpers.go#L175
        cpudelta = stat['cpu_stats']['cpu_usage']['total_usage']-stat['precpu_stats']['cpu_usage']['total_usage']
        total_cpu = stat['cpu_stats']['cpu_usage']['total_usage']
        precpudelta = stat['cpu_stats']['system_cpu_usage']-stat['precpu_stats']['system_cpu_usage']
        cpuload = (cpudelta/precpudelta)*100*len(stat['cpu_stats']['cpu_usage']['percpu_usage'])
        pids = stat['pids_stats']['current']

        net_i = sum([ stat['networks'][interface]['rx_bytes'] for interface in stat['networks'].keys()])
        net_o = sum([ stat['networks'][interface]['tx_bytes'] for interface in stat['networks'].keys()])


        block_i = 0
        block_o = 0
        try:
            block_i = stat['blkio_stats']['io_service_bytes_recursive'][5]['value']
            block_o = stat['blkio_stats']['io_service_bytes_recursive'][6]['value']
        except:
            #print(stat)
            print(stat['blkio_stats']['io_service_bytes_recursive'])
        
        #check first whether anything changed and then insert new numbers
        values = { 'cpuload' : cpuload,
                   'memoryusage' : memoryusage,
                   'total_cpu' : total_cpu,
                   'pids' : pids,
                   'net_i' : net_i,
                   'net_o' : net_o,
                   'block_i' : block_i,
                   'block_o' : block_o
                 }
        table_names = { 'cpuload' : 'containerstats_cpuload',
                   'memoryusage' :   'containerstats_mem',
                   'total_cpu' :   'containerstats_total_cpu',
                   'pids' : 'containerstats_pids',
                   'net_i' : 'containerstats_net_i',
                   'net_o' : 'containerstats_net_o',
                   'block_i' : 'containerstats_block_i',
                   'block_o' : 'containerstats_block_o'
                 }
        threshold = { 'cpuload' : 10, # in %00
                   'memoryusage' : 0.01,
                   'total_cpu' : 10000000000,
                   'pids' : 1,
                   'net_i' : 10**6,
                   'net_o' : 10**6,
                   'block_i' : 10**6,
                   'block_o' : 10**6
                  }
        s_type = { 'cpuload': 'c',
                   'memoryusage': 'a',
                   'total_cpu': 'a',
                   'pids': 'a',
                   'net_i': 'a',
                   'net_o': 'a',
                   'block_i': 'a',
                   'block_o': 'a'
                  }

        col_names = values.keys()
        for col_name in col_names:
           if check_last_changed(table_names[col_name], container_id, col_name, values[col_name],\
                  threshold[col_name], s_type[col_name]):
               1==1
               insert_new_row(table_names[col_name], container_id, col_name, values[col_name])


        if ic == 0:
            total_cpu = stat['cpu_stats']['system_cpu_usage']
            total_mem = stat['memory_stats']['limit']
            insert_item('system','total_cpu, total_mem', "%d', '%d"%(total_cpu, total_mem) )


TE = datetime.datetime.now()
print((TE-T0).total_seconds())
