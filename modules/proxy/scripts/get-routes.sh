# "backup" writes into $fnameb
# "restore" fills up proxy from $fnamer so it has tobe copied from $fnameb

IP=$1

SECRET=`grep "DUMMYPASS=" config.sh |sed 's/"/ /g' | awk '{print $2}'`


curl -H "Content-Type: application/json" -H "Authorization: token ${SECRET}" ${IP}:8001/api/routes |  python -m json.tool 

