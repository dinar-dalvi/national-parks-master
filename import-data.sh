#!/bin/bash

mongod &

#mongod --fork --dbpath=/mongodb/db --logpath=/mongodb/mongo.log &

mongoimport --drop -d demo -c nationalparks --type json --jsonArray --file ./national-parks.json $*


#start tomcat
echo "starting tomcat ... "

#sh /opt/tomcat/bin/catalina.sh stop

sh /opt/tomcat/bin/catalina.sh start


echo "started tomcat"

# keep the stdin
#/bin/bash
exec "$@"