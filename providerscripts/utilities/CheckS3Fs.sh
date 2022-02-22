#!/bin/sh

count=0

/bin/sleep 10

while ( [ "${count}" -lt "5" ] )
do
    if ( [ -f ${HOME}/runtime/PERFORMING_S3FS_CHECK ] && [ ! -f ${HOME}/runtime/MONITOR_S3FS ] )
    then
        /bin/rm ${HOME}/runtime/PERFORMING_S3FS_CHECK ${HOME}/runtime/MONITOR_S3FS
        exit
    else
        if ( [ -f ${HOME}/runtime/PERFORMING_S3FS_CHECK ] )
        then
            /bin/rm ${HOME}/runtime/PERFORMING_S3FS_CHECK
            /bin/echo "${0} `/bin/date`: Emergency reboot has happened because s3fs looks to have become unresponsive which hoses us if we don't reboot" >> ${HOME}/logs/UnresponsiveS3FSLog.dat
            /usr/sbin/shutdown -r now
        fi
    fi
    /bin/sleep 10
    count="`/usr/bin/expr ${count} + 1`"
done
        
