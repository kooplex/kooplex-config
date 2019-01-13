import psycopg2
import datetime, time
import pandas as pd
import datetime as dt

from numpy import *
import json

properties = { 'cpuload' : {'table_name' :'containerstats_cpuload',
                            'unit' : '%',
                            'conv' : 1/100,
                            'resample': 'sum',
                           },
               'total_cpu' : {'table_name' :'containerstats_total_cpu',
                            'unit' : '',
                            'conv' : 1,
                            'resample': 'max',
                           },
                'memoryusage' : {'table_name' :'containerstats_mem',
                            'unit' : 'MB',
                            'conv' : 1/1024**2,
                            'resample': 'max',
                           },  
                'pids' : {'table_name' :'containerstats_pids',
                            'unit' : '',
                            'conv' : 1,
                            'resample': 'max',
                           },  
                'net_i' : {'table_name' :'containerstats_net_i',
                            'unit' : 'MB',
                            'conv' : 1/1024**2,
                            'resample': 'sum',
                           },
                'net_o' : {'table_name' :'containerstats_net_o',
                            'unit' : 'MB',
                            'conv' : 1/1024**2,
                            'resample': 'sum',
                           },
                'block_i' : {'table_name' :'containerstats_block_i',
                            'unit' : 'MB',
                            'conv' : 1/1024**2,
                             'resample': 'sum',
                           },
                'block_o' : {'table_name' :'containerstats_block_o',
                            'unit' : 'MB',
                            'conv' : 1/1024**2,
                            'resample': 'sum',
                           }
                 }


def connect_to_database():
    conn = psycopg2.connect("host=kooplex-monitordb dbname=monitor user=usage_viewer password=whatisusage")
    return conn
    
class Container():
    """
    A docker container that belongs to a certain user and project
    """
    
    def __init__(self, c_id):
        """
        :param tables: dict of queried sql tables
        :param cid: docker container id
        :param name: docker container name
        :param running: whether docker container is running now
        :param last: collect only the last some data
        """
        
        self.tables = {}
        self.cid = c_id
        self.name = ""
        self.running = False
        self.user_name = ""
        self.project_name = ""
        self.last = False
        self.interval = ''
        #self._get_name()

    def get_usage(self, prop):
        """
        Get 'cpuload', 'memoryusage' etc. for a certain user and project
        """
        
        table_name = properties[prop]['table_name']
        if self.last:
            sqlc = "select * from %s where container_id = %d ORDER BY ID DESC LIMIT 1" % (table_name, self.cid)            
        else:
            sqlc = "select * from %s where container_id = %d" % (table_name, self.cid)
         
        if self.interval:
            sqlc = "select * from %s where container_id = %d and last_read >= (NOW() - INTERVAL '%s' )"\
            % (table_name, self.cid, self.interval)
        
        tdf = pd.read_sql(sqlc, connect_to_database())
        tdf.drop(['id'], axis=1, inplace=True)
        tdf['datetime'] = pd.to_datetime(tdf['last_read'], unit='s')
        tdf = tdf.set_index('datetime')            
        tdf.drop(['last_read'], axis=1, inplace=True)
        
        if tdf.empty:
            #print("%s EMPTY ERROR"%prop)
            self.tables[prop] = tdf
            return
        
        tdf = tdf.astype(float)
        
        if not self.last:
            if prop == 'cpuload':
                tdf = tdf.resample('2T').mean()
            elif prop == 'memoryusage':
                tdf = tdf.resample('2T').ffill()
            elif prop == 'total_cpu':
                tdf = tdf.resample('10T').ffill()

            tdf = tdf.fillna(value=0)
            
        self.tables[prop] = tdf

    def last_data(self, prop):
        tdf = self.tables[prop]
        tt = tdf[(datetime.datetime.now()-datetime.timedelta(minutes=10)).strftime("%Y-%m-%d %H:%M"):]
        if not self.running:
            return 0
        if prop == 'cpuload':
            if len(tt) == 0:
                return 0
            else:
                tt = tt.sort_index()
                return tt.iloc[-1][prop]
        else:
            return tdf.iloc[-1][prop]
    

    
class Usage_Data():
    def __init__(self):
        self.usage_dict = {}
        self.usage = {}
        self.containers = {}
        self.containers_info = pd.DataFrame(columns=['id', 'container_name', 'project', 'username'])
        self.selected_containers = []
        self.get_all_containers()
        self.total_memory = 0
        self.total_cpu = 0     
        #self.temp_df = None
        self.prop_to_use = None
    
    def get_system_usage(self, interval="1 minute"):
        sqlc = "select * from system where last_read >= (NOW() - INTERVAL '%s' )"%interval
        tdf = pd.read_sql(sqlc, connect_to_database())
        tdf.drop(['id'], axis=1, inplace=True)
        tdf['datetime'] = pd.to_datetime(tdf['last_read'], unit='s')
        tdf = tdf.set_index('datetime')            
        tdf.drop(['last_read'], axis=1, inplace=True)
        return tdf

    def get_all_containers(self):
        sqlc = "select ff.id, project, username, container_name, running from (select conts.id, project, hubuser, \
        container_name, running from container as conts inner join project as proj on conts.project_id = proj.id) \
        as ff inner join hubuser on ff.hubuser = hubuser.id;"
        self.containers_info = pd.read_sql(sqlc, connect_to_database())
        self.selected_containers = list(self.containers_info.id)        
        
    @property
    def number_of_containers(self):
        return  len(self.containers_info)

    @property
    def running_containers(self):
        return self.containers_info[self.containers_info.running==True].id
    
    def select_project_containers(self, project_name):
        c_ids = self.containers_info[self.containers_info.project == project_name].id
        self.selected_containers = list(c_ids)
        return self.selected_containers
        
    def select_user_containers(self, user_name):
        c_ids = self.containers_info[self.containers_info.username == user_name].id
        self.selected_containers = list(c_ids)
        return self.selected_containers        
    
    @property
    def list_all_projects(self):
        return self.containers_info.project.drop_duplicates()

    @property
    def list_all_users(self):
        return self.containers_info.username.drop_duplicates()

    @property
    def list_all_containers(self):
        return self.containers_info
    
    def gather_data(self, container_ids=[], properties=[], last=False):
        self.containers = {}
        self.get_all_containers()

        if container_ids:
            self.selected_containers  = container_ids
        
        if last:
            self.selected_containers = intersect1d(self.selected_containers, self.running_containers)
        for i in self.selected_containers:
            C = Container(i)
                        
            C.last = last
            #C.get_cpu_usage()
            #C.get_memory_usage()
            C.get_usage('cpuload')
            C.get_usage('memoryusage')
            info_for_C = self.containers_info[self.containers_info.id==C.cid]
            C.running = info_for_C['running'].iloc[0]
            C.user_name = info_for_C['username'].iloc[0]
            C.name = info_for_C['container_name'].iloc[0]
            self.containers[C.cid] = C

    def total_usage(self, prop, trunc):
        if prop==1:
            self.prop_to_use = 'cpuload'
        elif prop==2:
            self.prop_to_use = 'memoryusage'       
        return self._usage( sample_rate='m', trunc=trunc*30)
    
    def monthly_usage(self, prop, trunc):
        if prop==1:
            self.prop_to_use = 'cpuload'
        elif prop==2:
            self.prop_to_use = 'memoryusage'       
        return self._usage( sample_rate='m', trunc=trunc*30)
    
    #def weekly_usage(self, prop='cpuload', trunc=1):
    #def weekly_usage(self, prop=1, trunc=1):
    def weekly_usage(self, prop, trunc):
        if prop==1:
            self.prop_to_use = 'cpuload'
        elif prop==2:
            self.prop_to_use = 'memoryusage'
        return self._usage(sample_rate='w', trunc=trunc*7)

    #def daily_usage(self, prop='cpuload', trunc=1):
    def daily_usage(self, prop, trunc):
        if prop==1:
            self.prop_to_use = 'cpuload'
        elif prop==2:
            self.prop_to_use = 'memoryusage'
        return self._usage(sample_rate='d', trunc=trunc)
    
    def daily_usage_s(self, prop='cpuload', trunc=30):
        self.prop_to_use = prop
        return self._usage(sample_rate='d', trunc=trunc)
    
    def myplot(self):
        bars = hv.Bars(self.temp_df, ['datetime', 'project_name'], self.prop_to_use)
        return bars.relabel(group='Stacked')
    
    def _usage(self, sample_rate='d', trunc=1):
        #temporary df
        self.temp_df = pd.DataFrame()
        for cid in self.selected_containers:
            # select container data
            C = self.containers[cid]['container']
            # get the relevant table
            C_t = C.tables[self.prop_to_use].copy()
            # set the relevant time interval
            start_time = dt.datetime.now() - dt.timedelta(trunc) 
            # sort indices (it might be reordered)
            C_t.df = C_t.df.sort_index()
            # truncate data according t the relevant time interval
            C_t.df = C_t.df.truncate(before=start_time)
            # do anything only if we still have data
            if not C_t.is_empty:
                C_t.resample_df(sample_rate)
                C_t.add_labels()
                # put pd.Series into a pd.DataFrame
                self.temp_df = pd.concat([ self.temp_df, C_t.df])
                
        #return self.myplot()
        
   