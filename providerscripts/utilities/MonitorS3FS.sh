#!/bin/sh

/bin/touch ${HOME}/runtime/MONITOR_S3FS

#If this command times out then it means S3FS is having problems
/bin/ls ${HOME}/config

#If the above command times out, we will never get to here so the monitoring file won't be deleted and we can check for that in another script

/bin/rm ${HOME}/runtime/MONITOR_S3FS
