#!/bin/sh

export HOME="`/bin/cat /home/homedir.dat`"

if ( [ "${1}" != "" ] && [ "${2}" != "" ] )
then
    if ( [ "${3}" != "append" ] )
    then
       /bin/sed -i "/${1}/d" ${HOME}/.ssh/webserver_configuration_settings.dat
    fi
    /bin/echo "${1}:${2}" >> ${HOME}/.ssh/webserver_configuration_settings.dat
fi
