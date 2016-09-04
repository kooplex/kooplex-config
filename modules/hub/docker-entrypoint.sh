#!/bin/bash
set -e

if [ ! -e 'kooplexhub/kooplexhub/kooplex/settings.py' ]; then
        cp /settings.py kooplexhub/kooplexhub/kooplex/settings.py

fi

v=`echo "use comparetest_kooplex; show tables" | mysql -u root --password=almafa137 -h comparetest-mysql | wc| awk '{print $1}'`
if [ !  "$v" -gt "10" ]; then
        cd /kooplexhub/kooplexhub/; python3 manage.py migrate
fi

exec "$@"
