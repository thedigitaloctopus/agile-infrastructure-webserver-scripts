#!/bin/sh



if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh ENABLEEFS:1`" = "1" ] )
then
   exit
fi

if ( [ "`/usr/bin/awk '{print int(($1%3600)/60)}' /proc/uptime`" -lt "3" ] )
then
    exit
fi

/bin/touch ${HOME}/runtime/PERFORMING_S3FS_CHECK 
/bin/touch ${HOME}/runtime/MONITOR_S3FS

#If this command times out then it means S3FS is having problems
/bin/ls ${HOME}/config

#If the above command times out, we will never get to here so the monitoring file won't be deleted and we can check for that in another script

/bin/rm ${HOME}/runtime/MONITOR_S3FS
