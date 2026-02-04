#!/bin/sh
echo "Waiting for Debezium to start..."
while [ "$(curl -s -o /dev/null -w '%{http_code}' http://debezium:8083/)" -ne 200 ] ; do
  sleep 5
done

echo "Registering Postgres Connector..."
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" http://debezium:8083/connectors/ -d '{
  "name": "company-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "mainDb",
    "database.port": "5432",
    "database.user": "admin",
    "database.password": "admin",
    "database.dbname" : "mainDb",
    "topic.prefix": "server",
    "table.include.list": "public.company",
    "plugin.name": "pgoutput",
    "snapshot.mode": "no_data",
    "tombstones.on.delete": "false",
    "include.schema.changes": "false",
    "provide.transaction.metadata": "false"
  }
}'
