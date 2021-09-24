

if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] )
then
    /usr/bin/s3cmd get s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
    /bin/mv htpasswd /var/www/html/administrator
fi
