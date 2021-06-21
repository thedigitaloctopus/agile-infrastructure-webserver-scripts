#!/bin/sh

export HOME="`/bin/cat /home/homedir.dat`"

if ( [ "${1}" != "" ] && [ "${2}" = "stripped" ] )
then
    /bin/grep "${1}:" ${HOME}/.ssh/webserver_configuration_settings.dat | /usr/bin/awk -F':' '{$1=""; print $0}'
elif ( [ "${1}" != "" ] && [ "${2}" != "stripped" ] )
then 
    /bin/grep "${1}:" ${HOME}/.ssh/webserver_configuration_settings.dat
fi
