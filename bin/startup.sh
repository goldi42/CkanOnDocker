#!/bin/sh

set -eu -o pipefail

config_file="config/${environment}.ini"

echo "Waiting for other services to start CKAN"

echo "Waiting for solr"
until $(nc -zv solr 8983); do
    printf '.'
    sleep 5
done

echo "Waiting for postgres"
until $(nc -zv db 5432); do
    printf '.'
    sleep 5
done

echo "Waiting for redis"
until $(nc -zv redis 6379); do
    printf '.'
    sleep 5
done


echo "Update ckanconfig"
cp /build/ckan.json ./

echo "All servies are up starting CKAN..."

echo "Install CKAN extensions"
ckanbuilder install extensions

echo "Build Assets"
ckanbuilder build assets

echo "Activate CKAN plugins"
ckanbuilder configure plugins --configini_file ${config_file}

echo "Initialise database"
if [ $init_database -eq 1 ]; then
paster --plugin=ckan db init -c ${config_file}
fi

echo "Start application server"
gunicorn --paste ${config_file} --reload
