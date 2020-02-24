import docker
import smtplib
from email.mime.text import MIMEText
import MySQLdb
import psycopg2

client = docker.from_env()

dbText = "\n"

db = MySQLdb.connect(host="##PREFIX##-mysql",user="kooplex",passwd="##MYSQLPASS##",db="##PREFIXDB##" )
myCursor = db.cursor()

try:
    conn=psycopg2.connect("host='##PREFIX##-gitlabdb' port='5432' dbname='gitlabhq_production' user='postgres' password='##GITLABDBPASS##'")
except:
    dbText += "I am unable to connect to the database."

pgCursor = conn.cursor()

services=["impersonator","gitlab","gitlabdb","hub","ldap","monitor","mysql","nginx","owncloud","owncloud","mysql","owncloud-redis","proxy","dashboards-basic","kernelgateway-basic"]
lofmustrun = [ "##PREFIX##-"+ss for ss in services]

non_existent_container_names = []
problematic_containers = []
for container_name in lofmustrun:
  try:
    cnter = client.containers.get(container_name)
  except docker.errors.NotFound:
    non_existent_container_names.append(container_name)
  else:
    if cnter.status != "running":
      problematic_containers.append(cnter)

context = ""
context += "The names of non-existent containers:\n"
context += str(non_existent_container_names) + "\n"

problematic_containers.extend([cnter for cnter in client.containers.list(all=True) if (not cnter.name.startswith("kooplex-notebook-smoketest") and cnter.name.startswith("kooplex-notebook") and cnter.status != "ru

for cnter in problematic_containers:
  context += "problematic container: " + cnter.name + "\n"
  context += cnter.logs(tail=20).decode('utf-8') + "\n"

# USER TEST
myCursor.execute("SELECT khh.gitlab_id, au.username, au.email FROM auth_user au, kooplex_hub_hubuser khh WHERE au.id = khh.user_ptr_id;")
myData = myCursor.fetchall()

try:
    pgCursor.execute("""SELECT id, username, email FROM users;""")
except:
    dbText += "I can't SELECT from users\n"

pgData = pgCursor.fetchall()

for myrow in myData:
  found = False
  for pgrow in pgData:
    if myrow[0] == pgrow[0]:
      if myrow[2] != pgrow[2]:
        dbText += 'The user: ' + str(myrow[1]) + ' email address does not match between PostgreSQL DB ( ' + str(pgrow[2]) + ' ) and MySQL DB ( ' + str(myrow[2]) + ' )\n'
      found = True
      break
  if found == False:
    dbText += 'User: ' + str(myrow[1]) + ' can not be found in PostgreSQL DB\n'

for pgrow in pgData:
  found = False
  if pgrow[1] != 'ghost':
    for myrow in myData:
      if pgrow[0] == myrow[0]:
        found = True
        break
  else:
    found = True
  if found == False:
    dbText += 'User: ' + str(pgrow[1]) + ' can not be found in MySQL DB\n'

# PROJECT TEST
myCursor.execute("SELECT id, name, creator_id, creator_name, description FROM kooplex_hub_project;")
myData = myCursor.fetchall()

try:
    pgCursor.execute("""SELECT p.id, p.name, p.description, p.creator_id, u.username AS creator_name FROM projects p, users u WHERE p.creator_id = u.id;""")
except:
    dbText += "I can't SELECT from projects\n"

pgData = pgCursor.fetchall()

myDict = {}
for myrow in myData:
  myDict.setdefault(myrow[3], []).append(myrow[1])
pgDict = {}
for pgrow in pgData:
  pgDict.setdefault(pgrow[4], []).append(pgrow[1])
  try:
    vals = myDict[pgrow[4]]
    if pgrow[1] not in vals:
      dbText += 'Missing project in MySQL DB: ' + str(pgrow[1]) + ' (user: ' + str(pgrow[4]) + ' )\n'
  except KeyError:
    dbText += 'Missing user in MySQL DB: ' + str(pgrow[4]) + '\n'

for myrow in myData:
  try:
    vals = pgDict[myrow[3]]
    if myrow[1] not in vals:
      dbText += 'Missing project in PostgreSQL DB: ' + str(myrow[1]) + ' (user: ' + str(myrow[3]) + ' )\n'
  except KeyError:
    dbText += 'Missing user in PostgreSQL DB: ' + str(myrow[3]) + '\n'

myCursor.close()
pgCursor.close()

context += dbText

if len(non_existent_container_names) > 0 or len(problematic_containers) > 0 or len(dbText) > 1:
  smtp_server = '##SMTP##'
  msg = MIMEText(context)
  msg['Subject'] = '[ERROR] Kooplex problem(s)'
  msg['From'] = '##EMAIL##'
  msg['To'] = '##EMAIL##'
  s = smtplib.SMTP(smtp_server)
  s.send_message(msg)
  s.quit()

