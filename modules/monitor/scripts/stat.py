import docker
import psycopg2


def insert_item(table, col_name, value):
    sqlc = "INSERT INTO %s (%s) VALUES ('%s');" % (table, col_name, value)
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

def check_last_changed(table_name, hubuser_id, container_id, cols, change, s_type):
    sqlc = "select * from %s where hubuser_id = %d and container_id = %d \
      order by last_read desc limit 1;" % (table_name, hubuser_id, container_id)
    cur.execute(sqlc)
    res = cur.fetchone()
    if res:
        for icol, col_name in enumerate(cur.description):
            if col_name[0] in cols.keys() and cols[col_name[0]]>0:
                #print(hubuser_id, container_id, col_name[0], res[icol], cols[col_name[0]], abs(cols[col_name[0]] - res[icol])/change[col_name[0]])
                if s_type[col_name[0]] == 'c':
                    ins = cols[col_name[0]] > change[col_name[0]]
                else:
                    ins = res[icol] == 0 or abs(cols[col_name[0]] - res[icol]) > change[col_name[0]]
                if ins:
                    #print('Ins')
                    return True
    else:
        return True


def insert_newrow(table_name, hubuser_id, container_id, cols):
    col_names = ''
    values = ''
    for c in cols:
        col_names += "%s," % c
        values += "%d," % cols[c]

    sqlc = "INSERT INTO %s (hubuser_id, container_id, %s) VALUES (%d, %d, %s);" % \
           (table_name, col_names[:-1], hubuser_id, container_id, values[:-1])
    res = cur.execute(sqlc)
    conn.commit()

conn = psycopg2.connect("dbname=monitor user=postgres")
cur = conn.cursor()

client = docker.from_env()

container_list = client.containers.list()
for cont in container_list:
    #Get container name
    container_name = cont.attrs['Name']
    if container_name.split("-")[0] == '/nb':

        #Query for project, if it does not exist then insert it
        project_name = get_project_name(cont)

        res = get_item('project', 'project', project_name)
        if not res:
            insert_item('project', 'project', project_name)
            res = get_item('project', 'project', project_name)
        project_id = res[0]


        #Query for container_name, if it does not exist then insert it
        res = get_item('container', 'container_name', container_name)
        if not res:
            insert_item('container', 'container_name', container_name)
            res = get_item('container', 'container_name', container_name)
        container_id = res[0]



        #Query for hubuser, if it does not exist then insert it
        username = get_user_name(cont)

        res = get_item('hubuser', 'username', username)
        if not res:
            insert_item('hubuser', 'username', username)
            res = get_item('hubuser', 'username', username)
        hubuser_id = res[0]


        #Get statistics from container
        stat = cont.stats(decode=True, stream=False)

        memoryusage = stat['memory_stats']['usage']
        cpuload = int(stat['cpu_stats']['cpu_usage']['total_usage']/stat['cpu_stats']['system_cpu_usage']*10000+0.5)
        pids = stat['pids_stats']['current']

        #check first whether anything changed and then insert new numbers
        cols = { 'cpuload' : cpuload,
                 'memoryusage' : memoryusage,
                 'pids' : pids
                 }
        change = {'cpuload' : 10.0, # in %00
                 'memoryusage' : 0.01,
                 'pids' : 1
                  }
        s_type = {'cpuload': 'c',
                  'memoryusage': 'a',
                  'pids': 'a'
                  }
        if check_last_changed('containerstats_current', hubuser_id, container_id, cols, change, s_type):
            insert_newrow('containerstats_current', hubuser_id, container_id, cols)


        net_i = sum([ stat['networks'][interface]['rx_bytes'] for interface in stat['networks'].keys()])
        net_o = sum([ stat['networks'][interface]['tx_bytes'] for interface in stat['networks'].keys()])

        block_i = stat['blkio_stats']['io_service_bytes_recursive'][5]['value']
        block_o = stat['blkio_stats']['io_service_bytes_recursive'][6]['value']

        #check first whether anything changed
        cols = { 'net_i' : net_i,
                 'net_o' : net_o,
                 'block_i' : block_i,
                 'block_o' : block_o
                 }
        change = { 'net_i' : 10**6,
                   'net_o' : 10**6,
                   'block_i' : 10**6,
                   'block_o' : 10**6
                 }
        s_type = {'net_i': 'a',
                  'net_o': 'a',
                  'block_i': 'a',
                  'block_o': 'a'
                  }
        if check_last_changed('containerstats_aggregate', hubuser_id, container_id, cols, change, s_type):
            insert_newrow('containerstats_aggregate', hubuser_id, container_id, cols)


