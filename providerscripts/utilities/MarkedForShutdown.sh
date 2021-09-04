if ( [ -f ${HOME}/runtime/MARKEDFORSHUTDOWN ] )
then
    /bin/rm ${HOME}/runtime/MARKEDFORSHUTDOWN
    /usr/sbin/shutdown -h now
fi
