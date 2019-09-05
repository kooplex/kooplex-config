# "backup" writes into $fnameb
# "restore" fills up proxy from $fnamer so it has tobe copied from $fnameb

IP=$1

SECRET=`grep "DUMMYPASS=" config.sh |sed 's/"/ /g' | awk '{print $2}'`


fnamer="/tmp/proxyroute-res ";  $2 || fnamer=$2 
while IFS=$'}' read -ra ADDR; do
     for i in "${ADDR[@]}"; do
         line=`echo $i | sed -e 's/{//g'`
         path=`echo ${line%%:*} | sed -e 's/"//g' -e 's/\///' -e 's/,//'`
         json=`echo "{"${line#*:}"}" `
         #$i | sed -e 's/{//g'
         echo $path
         echo curl -X POST -H "Content-Type: application/json" -H "Authorization: token ${SECRET}" ${IP}:8001/api/routes/$path  --data $json
             done
done <<< `cat $fnamer`
