#! /bin/bash



# while ! echo "show databases" | mysql -u root --password=##HUBDBROOTPW## -h ##PREFIX##-hub-mysql  | grep  ##HUBDB##
# do
#   echo "CREATE DATABASE ##HUBDB##; CREATE USER '##HUBDBUSER##'@'%' IDENTIFIED BY '##HUBDBPW##'; GRANT ALL ON ##HUBDB##.* TO '##HUBDBUSER##'@'%';" |  mysql -u root --password=##HUBDBROOTPW##  -h ##PREFIX##-hub-mysql
#   sleep 5;
# done;
# echo MYSQL created!;

# mount -o bind /mnt/volumes/home/ /home 

cd /kooplexhub/kooplexhub/
git pull
/usr/bin/python3 manage.py makemigrations hub
/usr/bin/python3 manage.py migrate
/usr/bin/python3 manage.py runserver 0.0.0.0:80
