if ( [ "`/bin/grep "${1}:" ${HOME}/.ssh/webserver_configuration_settings.dat | /usr/bin/awk -F':' '{print $NF}'`" = "${2}" ] )
then
    /bin/echo "0"
else
    /bin/echo "1" 
fi
