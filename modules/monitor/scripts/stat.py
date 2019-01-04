import docker
import psycopg2


def insert_item(table, col_name, value):
    sqlc = "INSERT INTO %s (%s) VALUES ('%s');" % (table, col_name, value)
    cur.execute(sqlc)
    conn.commit()

def update_item(table, col_name, value, exist_col_name, exist_value):
    sqlc = "UPDATE %s SET %s = '%s' WHERE %s = '%s';" % (table, col_name, value, exist_col_name, exist_value)
    print(sqlc)
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
    sqlc = "INSERT INTO %s (container_id, %s) VALUES (%d, %s);" % \
           (table_name, col_name, container_id, value)
    #print(sqlc)
    res = cur.execute(sqlc)
    conn.commit()

conn = psycopg2.connect("dbname=monitor user=postgres")
cur = conn.cursor()

client = docker.from_env()
container_list = client.containers.list()
for cont in container_list:
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
        if res and not res[1]:
            update_item('container', 'project_id', "%d"%project_id, 'container_name', container_name, 'hubuser',"%d"%hubuser_id)
        if not res:
            insert_item('container', 'project_id, container_name, hubuser', "%d', '%s', '%d"%(project_id, container_name, hubuser_id))
            res = get_item('container', 'container_name', container_name)
        container_id = res[0]






        #Get statistics from container
        stat = cont.stats(stream=False)

        try:
           memoryusage = stat['memory_stats']['usage']
           cpudelta = stat['cpu_stats']['cpu_usage']['total_usage']-stat['precpu_stats']['cpu_usage']['total_usage']
           precpudelta = stat['cpu_stats']['system_cpu_usage']-stat['precpu_stats']['system_cpu_usage']
           cpuload = (cpudelta/precpudelta)*100*len(stat['cpu_stats']['cpu_usage']['percpu_usage'])
           pids = stat['pids_stats']['current']
   
           net_i = sum([ stat['networks'][interface]['rx_bytes'] for interface in stat['networks'].keys()])
           net_o = sum([ stat['networks'][interface]['tx_bytes'] for interface in stat['networks'].keys()])
   
           block_i = stat['blkio_stats']['io_service_bytes_recursive'][5]['value']
           block_o = stat['blkio_stats']['io_service_bytes_recursive'][6]['value']
        except Exception as e:
            print(e)
            print(container_name)
            print(stat)
        
        #check first whether anything changed and then insert new numbers
        values = { 'cpuload' : cpuload,
                   'memoryusage' : memoryusage,
                   'pids' : pids,
                   'net_i' : net_i,
                   'net_o' : net_o,
                   'block_i' : block_i,
                   'block_o' : block_o
                 }
        table_names = { 'cpuload' : 'containerstats_cpuload',
                   'memoryusage' :   'containerstats_mem',
                   'pids' : 'containerstats_pids',
                   'net_i' : 'containerstats_net_i',
                   'net_o' : 'containerstats_net_o',
                   'block_i' : 'containerstats_block_i',
                   'block_o' : 'containerstats_block_o'
                 }
        threshold = { 'cpuload' : 10, # in %00
                   'memoryusage' : 0.01,
                   'pids' : 1,
                   'net_i' : 10**6,
                   'net_o' : 10**6,
                   'block_i' : 10**6,
                   'block_o' : 10**6
                  }
        s_type = { 'cpuload': 'c',
                   'memoryusage': 'a',
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

        

