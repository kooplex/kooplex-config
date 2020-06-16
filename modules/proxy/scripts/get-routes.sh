# "backup" writes into $fnameb
# "restore" fills up proxy from $fnamer so it has tobe copied from $fnameb

. lib.sh

IP=`docker network inspect $PREFIX-net | grep proxy -A 3 |tail -n 1 | sed -e 's,",,g'| sed -e 's,/, ,g'| awk '{print $2}'`
#SECRET=`grep "DUMMYPASS=" config.sh |sed 's/"/ /g' | awk '{print $2}'`


curl -H "Content-Type: application/json" -H "Authorization: token ${DUMMYPASS}" ${IP}:8001/api/routes |  python -m json.tool 

