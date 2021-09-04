if ( [ -f ${HOME}/runtime/MARKEDFORSHUTDOWN ] )
then
    /bin/rm ${HOME}/runtime/MARKEDFORSHUTDOWN
    ${HOME}/providerscripts/utilities/ShutdownThisWebserver.sh
fi
