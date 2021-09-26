#!/bin/sh

if ( [ ! -f ${HOME}/config/INSTALLEDSUCCESSFULLY ] )
then
    exit
fi

BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"

if ( [ ! -d /etc/basicauth ] )
then
    /bin/mkdir /etc/basicauth
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] || [ ! -f /etc/basicauth/.htpasswd ] )
    then
        /usr/bin/s3cmd get s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /etc/basicauth/.htpasswd
        /bin/chown www-data.www-data /etc/basicauth/.htpasswd
        /bin/sleep 40
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] || [ ! -f /etc/basicauth/.htpasswd ] )
    then
        /usr/bin/s3cmd get s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /etc/basicauth/.htpasswd
        /bin/chown www-data.www-data /etc/basicauth/.htpasswd
        /bin/sleep 40
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
    if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] || [ ! -f /etc/basicauth/.htpasswd ] )
    then
        /usr/bin/s3cmd get s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /etc/basicauth/.htpasswd
        /bin/chown www-data.www-data /etc/basicauth/.htpasswd
        /bin/sleep 40
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] || [ ! -f /etc/basicauth/.htpasswd ] )
    then
        /usr/bin/s3cmd get s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /etc/basicauth/.htpasswd
        /bin/chown www-data.www-data /etc/basicauth/.htpasswd
        /bin/sleep 40
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi
