# "backup" writes into $fnameb
# "restore" fills up proxy from $fnamer so it has tobe copied from $fnameb



case $1 in
 'backup') 
  fnameb="/tmp/proxyroute-bak ";  $2 || fnameb=$2 
  curl -H "Authorization: token almafa137" 172.20.0.9:8001/api/routes  > $fnameb

  ;;
 'restore')

  fnamer="/tmp/proxyroute-res ";  $2 || fnamer=$2 
  while IFS=$'}' read -ra ADDR; do
      for i in "${ADDR[@]}"; do
          line=`echo $i | sed -e 's/{//g'`
          path=`echo ${line%%:*} | sed -e 's/"//g' -e 's/\///' -e 's/,//'`
          json=`echo "{"${line#*:}"}" `
          #$i | sed -e 's/{//g'
          echo $path
          curl -X POST -H "Content-Type: application/json" -H "Authorization: token almafa137" 172.20.0.9:8001/api/routes/$path  --data $json
              done
 done <<< `cat $fnamer`
# '{"target":"http://172.20.20.136:8000"}' 
 ;;
esac
