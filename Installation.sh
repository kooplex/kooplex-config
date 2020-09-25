for module in data_courses data_garbage data_git data_homes  data_reports  data_share base nginx ldap proxy gitea hydra report-nginx hub impersonator #notebook 
do
        bash kooplex.sh build $module
done

bash kooplex.sh start nginx 
bash kooplex.sh start ldap 
bash kooplex.sh start proxy 
bash kooplex.sh start hydra

for module in nginx ldap proxy gitea seafile hydra report-nginx hub #notebook 
do
        bash kooplex.sh install-nginx $module
done

bash kooplex.sh install hydra
bash kooplex.sh install gitea 
bash kooplex.sh install seafile
bash kooplex.sh install report-nginx
bash kooplex.sh install hub

bash kooplex.sh start gitea 
bash kooplex.sh build seafile
bash kooplex.sh start seafile
bash kooplex.sh start report-nginx
bash kooplex.sh start hub
bash kooplex.sh build impersonator 
bash kooplex.sh start impersonator 

# Stopping and removing everything
for module in gitea seafile hydra report-nginx impersonator nginx ldap proxy hub #notebook 
do
        bash  kooplex.sh stop $module
done

for module in gitea seafile hydra report-nginx impersonator nginx ldap proxy hub #notebook 
do
        bash  kooplex.sh remove $module
done

for module in gitea seafile hydra report-nginx impersonator nginx ldap proxy hub notebook data_courses data_garbage data_git data_homes  data_reports  data_share 
do
        bash  kooplex.sh purge $module
done

for module in gitea seafile hydra report-nginx impersonator nginx ldap proxy hub notebook
do
        bash kooplex.sh clean $module
done


# Apply patches manually for services (check Readme.md in module directories)
# * seafile
# * gitea
# 
# SETUP services in hub admin
# * Add VC repositories
# * Add
# 
# * Add notebook images:
#   * build them in kooplex-config
#   * enter to the hub container and manage.py updatemodel


