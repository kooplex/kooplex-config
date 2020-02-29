# "backup" writes into $fnameb
# "restore" fills up proxy from $fnamer so it has tobe copied from $fnameb

IP=$1

SECRET=`grep "DUMMYPASS=" config.sh |sed 's/"/ /g' | awk '{print $2}'`

PATH_TODEL=$2

curl -X DELETE  -H "Content-Type: application/json" -H "Authorization: token ${SECRET}" ${IP}:8001/api/routes$PATH_TODEL

