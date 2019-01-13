from monitor import *

#top_users
top_users = pd.DataFrame(columns=['user_name', 'Total_CPU_Usage'])

Usage = Usage_Data()

P = properties
for user_name in Usage.list_all_users:
    cpu = 0

    Usage.select_user_containers(user_name)
    for cid in Usage.selected_containers:
        C = Container(cid)
        C.last = True
        C.get_usage('total_cpu')
        tcpu = C.tables['total_cpu']['total_cpu'].max()
        if tcpu is not NAN:
            cpu += tcpu
        
    stat = {'user_name': user_name, 'Total_CPU_Usage': cpu}
    top_users = top_users.append(stat,  ignore_index=True)
    
top_users.to_pickle('Top_users.p')



#top_projects
top_projects = pd.DataFrame(columns=['project_name', 'Total_CPU_Usage'])
Usage = Usage_Data()

P = properties
for project_name in Usage.list_all_projects:
    cpu = 0
    Usage.select_project_containers(project_name)
    for cid in Usage.selected_containers:
        C = Container(cid)
        C.last = True
        C.get_usage('total_cpu')
        tcpu = C.tables['total_cpu']['total_cpu'].max()
        if tcpu is not NAN:
            cpu += tcpu
        
    stat = {'project_name': project_name, 'Total_CPU_Usage': cpu}
    top_projects = top_projects.append(stat,  ignore_index=True)

top_projects.to_pickle('Top_projects.p')
