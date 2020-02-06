#####################################################################################################################################
# Description: This script will monitor for low memory states and record them on the shared filesystem
# Author: Peter Winter
# 05/04/2017
#####################################################################################################################################
#!/bin/sh

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
then
    exit
fi

MEMORY="`/bin/cat /proc/meminfo | grep MemFree | /usr/bin/awk '{print $2}'`"
IP="`${HOME}/providerscripts/utilities/GetIP.sh`"

if ( [ ! -d ${HOME}/config/lowmemoryaudit/webservers/${IP} ] )
then
    /bin/mkdir -p ${HOME}/config/lowmemoryaudit/webservers/${IP}
fi

if ( [ "${MEMORY}" -lt "100000" ] )
then
    /bin/echo "LOW MEMORY state detected `/bin/date` VALUE: ${MEMORY} KB remaining" >> ${HOME}/config/lowmemoryaudit/${IP}/lowmemoryaudittrail.dat
    ${HOME}/providerscripts/email/SendEmail.sh "LOW MEMORY STATE DETECTED" "LOW MEMORY state detected `/bin/date` VALUE: ${MEMORY} KB remaining on machine with ip address: `${HOME}/providerscripts/utilities/GetPublicIP.sh`"
fi
