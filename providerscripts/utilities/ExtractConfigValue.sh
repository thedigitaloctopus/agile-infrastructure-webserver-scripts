
if ( [ "${1}" != "" ] )
then
    /bin/grep "${1}:" ${HOME}/.ssh/webserver_configuration_settings.dat | /usr/bin/awk -F':' '{print $NF}'
fi
