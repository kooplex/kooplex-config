#!/bin/sh

echo "Executing proxy at $CHP_PUBLICIP, $CHP_ADMINIP"

cd /srv/configurable-http-proxy
exec configurable-http-proxy \
    --ip $PUBLICIP \
    --api-ip $ADMINIP
