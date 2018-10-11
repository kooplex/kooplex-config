#! /bin/bash



# while ! echo "show databases" | mysql -u root --password=##HUBDBROOT_PW## -h ##PREFIX##-hub-mysql  | grep  ##HUBDB##
# do
#   echo "CREATE DATABASE ##HUBDB##; CREATE USER '##HUBDB_USER##'@'%' IDENTIFIED BY '##HUBDB_PW##'; GRANT ALL ON ##HUBDB##.* TO '##HUBDB_USER##'@'%';" |  mysql -u root --password=##HUBDBROOT_PW##  -h ##PREFIX##-hub-mysql
#   sleep 5;
# done;
# echo MYSQL created!;

# mount -o bind /mnt/volumes/home/ /home 

#FIXME: this is not nice
echo -e "*/1 * * * * /usr/bin/python3 /kooplexhub/kooplexhub/manage.py scheduler\n" > /var/spool/cron/crontabs/root
/etc/init.d/cron start
###########

cd /kooplexhub/kooplexhub/
#git pull
/usr/bin/python3 manage.py makemigrations hub
/usr/bin/python3 manage.py migrate
/usr/bin/python3 manage.py runserver 0.0.0.0:80
