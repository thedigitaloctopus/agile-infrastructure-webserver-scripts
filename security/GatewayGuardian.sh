#!/bin/sh

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
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
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/VIRGINADJUSTED ] )
        then
            /usr/bin/s3cmd mv s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$
            /bin/touch ${HOME}/runtime/VIRGINADJUSTED
        fi
        /usr/bin/s3cmd get --force s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /etc/basicauth/.htpasswd
        /bin/chown www-data.www-data /etc/basicauth/.htpasswd
        /bin/sleep 130
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] || [ ! -f /etc/basicauth/.htpasswd ] )
    then
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/VIRGINADJUSTED ] )
        then
            /usr/bin/s3cmd mv s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$
            /bin/touch ${HOME}/runtime/VIRGINADJUSTED
        fi
        /usr/bin/s3cmd get --force s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /etc/basicauth/.htpasswd
        /bin/chown www-data.www-data /etc/basicauth/.htpasswd
        /bin/sleep 130
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
    if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] || [ ! -f /etc/basicauth/.htpasswd ] )
    then
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/VIRGINADJUSTED ] )
        then
            /usr/bin/s3cmd mv s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$
            /bin/touch ${HOME}/runtime/VIRGINADJUSTED
        fi
        
        /usr/bin/s3cmd get --force s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /etc/basicauth/.htpasswd
        /bin/chown www-data.www-data /etc/basicauth/.htpasswd
        /bin/sleep 130
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    if ( [ -f ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED ] || [ ! -f /etc/basicauth/.htpasswd ] )
    then
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/VIRGINADJUSTED ] )
        then
            /usr/bin/s3cmd mv s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$
            /bin/touch ${HOME}/runtime/VIRGINADJUSTED
        fi
        
        /usr/bin/s3cmd get --force s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
        /bin/mv htpasswd /etc/basicauth/.htpasswd
        /bin/chown www-data.www-data /etc/basicauth/.htpasswd
        /bin/sleep 130
        /bin/rm ${HOME}/config/credentials/GATEWAY_GUARDIAN_UPDATED
    fi
fi
