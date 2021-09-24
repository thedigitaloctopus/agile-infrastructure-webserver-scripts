
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"


if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] )
then
    /usr/bin/s3cmd get s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
    /bin/mv htpasswd /var/www/html/administrator/.htpasswd
    /bin/chown www-data.www-data /var/www/html/administrator/.htpasswd
    /bin/sleep 40
    /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
fi
