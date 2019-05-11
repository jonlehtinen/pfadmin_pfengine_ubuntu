#!/bin/bash

if [ $NODE_ROLE = "CLUSTERED_CONSOLE" ] ; then
    aws s3 cp $DATA_HOME/data.zip $PF_HOME/server/default/data/drop-in-deployer/data.zip
fi

$PF_HOME/bin/run.sh &

if [ $NODE_ROLE = "CLUSTERED_CONSOLE" ] ; then
    sleep 120
    $PF_HOME/bin/replicate.sh &
    sleep 1680
    $PF_HOME/bin/export.sh &
fi

sleep infinity
