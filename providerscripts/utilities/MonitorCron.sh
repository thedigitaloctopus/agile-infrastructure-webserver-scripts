#!/bin/sh


while ( [ 1 ] )
do
   if ( [ "`/bin/cat /var/log/syslog | /bin/grep -i CRON | /bin/grep fork | /bin/grep error`" != "" ] )
   then
      /bin/sed -i '/.*error.*fork.*/d' /var/log/syslog  
   fi
   /bin/sleep 60
done
