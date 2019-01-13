from monitor import *

#hourly_usage
daily_usage = pd.DataFrame(columns=['project_name', 'user_name', 'cpuload'])
Usage = Usage_Data()

P = properties
Usage.get_all_containers()
for cid in Usage.selected_containers:
    C = Container(cid)
    info_for_C = Usage.containers_info[Usage.containers_info.id==C.cid]
    C.user_name = info_for_C['username'].iloc[0]
    project_name = info_for_C['project'].iloc[0]
    C.interval = '1 hour'
    C.get_usage('cpuload')
    tcpu = C.tables['cpuload']['cpuload']

    stat = pd.DataFrame(tcpu)
    stat['project_name'] = project_name
    stat['user_name'] = C.user_name
    daily_usage = daily_usage.append(stat)

# sys_df = Usage.get_system_usage("1 hour")
# sys_df.drop(['total_mem'], axis=1, inplace=True)
# sys_df['project_name'] = 'SYSTEM'
# sys_df['user_name'] = 'SYSTEM'
# daily_usage = daily_usage.append(stat)
#daily_usage.to_json('daily_usage.json')
daily_usage.to_pickle('hourly_usage.p')