#!/bin/bash
set -e

if [ ! -e 'kooplexhub/kooplexhub/kooplex/settings.py' ]; then
        cp /settings.py kooplexhub/kooplexhub/kooplex/settings.py

fi

v=`echo "use compare_kooplex; show tables" | mysql -u root --password=almafa137 -h compare-mysql | wc| awk '{print $1}'`
if [ !  "$v" -gt "10" ]; then
        cd /kooplexhub/kooplexhub/; python3 manage.py migrate; cd /
fi

exec "$@"
