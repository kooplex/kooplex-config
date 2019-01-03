#! /bin/bash
# Author: Jozsef Steger
# Summary: dashboard server starter script.
#          In case of a failure we sleep for a while to allow a user with administrative (docker) privilege to execute code in the container to check/heal.

cd $(dirname $0)
npm run start
date
echo "OOOPS: the server process stopped. Sleeping for 120 secs before entirily stopping the execution of script $0"
sleep 120
echo "----"
