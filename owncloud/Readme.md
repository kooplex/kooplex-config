#Owncloud to share files and data with each other
There is a dockerized version on docker-hub, which is complete except for the LDAP libraries for php. So we take the Dockerfile from the 9.0 version and add some extra lines.
https://hub.docker.com/_/owncloud/
See Dockerfile for further details

```bash
docker build -f Dockerfile -t owncloud-ldap .

#
docker run -d  -p 86:80 owncloud-ldap
```

We still need to attach the data folder and others
* -v /<mydatalocation>/apps:/var/www/html/apps installed / modified apps
* -v /<mydatalocation>/config:/var/www/html/config local configuration
* -v /<mydatalocation>/data:/var/www/html/data the actual data of your ownCloud

