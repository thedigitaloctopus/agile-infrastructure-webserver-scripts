#!/bin/sh

BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] || [ ! -f /var/www/html/administrator/.htpasswd ] )
    then
        /usr/bin/s3cmd get s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /var/www/html/administrator/.htpasswd
        /bin/chown www-data.www-data /var/www/html/administrator/.htpasswd
        /bin/sleep 40
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] || [ ! -f /var/www/html/wp-admin/.htpasswd ] )
    then
        /usr/bin/s3cmd get s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /var/www/html/wp-admin/.htpasswd
        /bin/chown www-data.www-data /var/www/html/wp-admin/.htpasswd
        /bin/sleep 40
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi
