#!/bin/bash
while true
do 
    datetime=`date '+%Y_%m_%d_%H%M'`;
    echo "Starting configuration export..."
    curl 'PF_EXPORT' \
     -H 'authorization: Basic PF_HEADER' \
     -H 'x-xsrf-header: PingFederate' \
     -H 'content-type: application/zip' \
     -o /tmp/data.zip
    sleep 30s
    aws s3 cp /tmp/data.zip $DATA_HOME/data_$datetime.zip
    aws s3 cp /tmp/data.zip $DATA_HOME/data.zip
    echo "Configuration export complete."
    sleep 1770s
done &
