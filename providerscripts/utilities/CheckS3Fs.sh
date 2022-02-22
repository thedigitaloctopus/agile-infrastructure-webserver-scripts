#!/bin/sh

count=0

while ( [ "${count}" -lt "10" ] )
do
    if ( [ -f ${HOME}/runtime/PERFORMING_S3FS_CHECK ] && [ ! -f ${HOME}/runtime/MONITOR_S3FS ] )
    then
        /bin/rm ${HOME}/runtime/PERFORMING_S3FS_CHECK ${HOME}/runtime/MONITOR_S3FS
    else
        shutdown -r now
    fi
done
        
