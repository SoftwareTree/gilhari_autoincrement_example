#!/bin/sh
# A shell script to invoke some sample curl commands on a Linux machine 
# against a running container image of the app-specific Gilhari microservice 
# gilhari_autoincrement_example:1.0
# 
# The responses are recorded in a log file (curl.log).
#
# Note that these curl commands use a mapped port number of 80
# even though the port number exposed by the app-specific 
# microservice may be different (e.g., 8081) inside the container shell.
# If you want to use these curl commands from inside the
# container shell on the host machine, you may have to use
# the exposed port number (e.g., 8081) instead.

# Optional first argument: port number (default 80)
port="${1:-80}"

echo -e "** BEGIN OUTPUT **" > curl.log

# Check that the Gilhari microservice is up before sending any other requests
echo "** Check the health of the Gilhari microservice" >> curl.log
if ! curl -fsS "http://localhost:${port:-80}/gilhari/v1/health/check" >> curl.log 2>&1; then
    echo "" >> curl.log
    echo "The Gilhari microservice is not responding at http://localhost:${port:-80}/gilhari/v1/" | tee -a curl.log
    echo "Start it first (e.g., ./gilhari/run_docker_app.sh) and wait until it is ready." | tee -a curl.log
    exit 1
fi
echo "" >> curl.log
echo "" >> curl.log

echo "** Delete all Employee2 objects to start fresh" >> curl.log
curl -X DELETE "http://localhost:$port/gilhari/v1/Employee2" >> curl.log
echo "" >> curl.log

echo -e "** Insert one Employee2 object \n" >> curl.log
curl -X POST "http://localhost:$port/gilhari/v1/Employee2"  -H 'Content-Type: application/json' -d '{"entity":{"name":"John39","compensation":54039,"exempt":true,"DOB":381484800390}}' >> curl.log
echo -e "" >> curl.log

echo "** Query all Employee2 objects" >> curl.log
curl -X GET   "http://localhost:$port/gilhari/v1/Employee2"  -H 'Content-Type: application/json' >> curl.log
echo "" >> curl.log

echo "** Insert multiple (two) Employee2 objects" >> curl.log
curl -X POST "http://localhost:$port/gilhari/v1/Employee2"  -H 'Content-Type: application/json' -d '{"entity":[{"name":"Mike40","compensation":54040,"exempt":false,"DOB":381484800400}, {"name":"Mary41","compensation":54041,"exempt":true,"DOB":381484800410}]}' >> curl.log
echo "" >> curl.log

echo "** Query all Employee2 objects" >> curl.log
curl -X GET   "http://localhost:$port/gilhari/v1/Employee2"  -H 'Content-Type: application/json' >> curl.log
echo "" >> curl.log

echo "** Query non-exempted Employee2 objects" >> curl.log
curl -X GET   "http://localhost:$port/gilhari/v1/Employee2?filter=exempt=0"  -H 'Content-Type: application/json' >> curl.log
echo "" >> curl.log

echo "** Query the count of exempted Employee2 objects" >> curl.log
curl -X GET   "http://localhost:$port/gilhari/v1/Employee2/getAggregate?attribute=id&aggregateType=COUNT&filter=exempt=1"  -H 'Content-Type: application/json' >> curl.log
echo "" >> curl.log

echo "** Delete all exempted Employee2 objects" >> curl.log
curl -X DELETE "http://localhost:$port/gilhari/v1/Employee2?filter=exempt=1" >> curl.log
echo "" >> curl.log

echo "** Query the count of all exempted Employee2 objects" >> curl.log
curl -X GET   "http://localhost:$port/gilhari/v1/Employee2/getAggregate?attribute=id&aggregateType=COUNT&filter=exempt=1"  -H 'Content-Type: application/json' >> curl.log
echo "" >> curl.log

echo "** Delete all Employee2 objects" >> curl.log
curl -X DELETE "http://localhost:$port/gilhari/v1/Employee2" >> curl.log
echo "" >> curl.log

echo "** Query the count of all Employee2 objects" >> curl.log
curl -X GET   "http://localhost:$port/gilhari/v1/Employee2/getAggregate?attribute=id&aggregateType=COUNT"  -H 'Content-Type: application/json' >> curl.log
echo "" >> curl.log

echo "** END OUTPUT **" >> curl.log
echo "" >> curl.log

cat curl.log
