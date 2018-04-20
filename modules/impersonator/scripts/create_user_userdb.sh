# docker $DOCKERARGS exec ${PREFIX}-impersonator bash -c /create_user_userdb.sh
username="vmi"
password="vvv"
psql -c "CREATE USER $username WITH PASSWORD '$password';"
psql -c "CREATE DATABASE $username WITH ENCODING 'utf8' OWNER $username CONNECTION LIMIT=-1;"

psql $username -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology; CREATE EXTENSION fuzzystrmatch; CREATE EXTENSION postgis_tiger_geocoder; CREATE EXTENSION pgrouting;"
psql $username -c "GRANT USAGE ON SCHEMA topology TO $username; GRANT ALL ON ALL TABLES IN SCHEMA topology TO $username; GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA topology TO $username;"
