#!/bin/sh
#####################################################################################
# Description: This script will update update the database credentials for wordpress
# Author: Peter Winter
# Date: 05/01/2017
#####################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#####################################################################################
#####################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS-secured`" = "1" ] )
then
    if ( [ ! -f  ${HOME}/runtime/SSHTUNNELCONFIGURED ] )
    then
        exit
    fi
    host="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    host="${dbip}"
fi

if ( [ -f /var/www/wp-config.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${database}`" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${host}`" != "" ] )
then
    exit
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/wordpress-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
    if ( [ -f /var/www/html/wordfence-waf.php ] )
    then
        /bin/cat ${HOME}/providerscripts/application/configuration/wordfence.txt >> /var/www/html/.htaccess
    fi
fi

if ( [ ! -f /var/www/html/.user.ini ] && [ -f /var/www/html/wordfence-waf.php ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/wordpress.user.ini /var/www/html/.user.ini
    /bin/chown www-data.www-data /var/www/html/.user.ini
    /bin/chmod 440 /var/www/html/.user.ini
fi


if ( [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

if ( [ ! -f ${HOME}/config/wordpress_config.php ] )
then
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/config/wordpress_config.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${host}`" != "" ] )
then
    :
else
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ ! -f ${HOME}/runtime/wordpress_config.php ] )
then
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/.ssh/BUILDARCHIVECHOICE:virgin ] )
then
    exit
fi

#If we the default configuration file hasn't been set yet, then exit. It will be on the shared config directory or the
#not shared runtime directory on an application by application basis
if ( [ ! -f ${HOME}/config/APPLICATION_CONFIGURATION_PREPARED ] && [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ -f ${HOME}/config/APPLICATION_DB_CONFIGURED ] || [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ]  )
then
    exit
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DB_PORT'`"

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    database="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    password="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    name="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"
fi

#if ( [ "`/bin/cat /var/www/html/index.php | /bin/grep session_save_path`" = "" ] )
#then
#    /bin/sed -i '1 s/^.*$/<?php \nsession_save_path \(\"\/var\/www\/html\/wp-content\/uploads\/\"\);/' /var/www/html/index.php
#fi

if ( [ ! -f ${HOME}/config/wordpress_config.php ] )
then
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ ! -f /var/www/DELETE_ME ] )
then
    if ( [ -f ${HOME}/applicationscripts/nuocialboss-wordpress/DELETE_ME ] )
    then
        /bin/mv ${HOME}/applicationscripts/nuocialboss-wordpress/DELETE_ME /var/www
        /bin/chmod 400 /var/www/DELETE_ME
        /bin/chown www-data.www-data /var/www/DELETE_ME
    fi
fi

#Record which configuration file we are working on for use elsewhere as needed
/bin/touch ${HOME}/.ssh/CONFIGFILE:wordpress_config.php

if ( [ -f ${HOME}/config/wordpress_config.php ] &&
    [ -f ${HOME}/config/APPLICATION_DB_CONFIGURED ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/config/APPLICATION_DB_CONFIGURED
    if ( [ ! -f /var/www/wp-config.php ] )
    then
        /bin/cp ${HOME}/config/wordpress_config.php /var/www/wp-config.php
        exit
    else
        exit
    fi
else
    /bin/cp /var/www/html/wp-config.php.default ${HOME}/runtime/wordpress_config.php
fi

/bin/sed -i "/DB_HOST/c\ define('DB_HOST', \"${host}:${DB_PORT}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database host name" >> ${HOME}/logs/MonitoringLog.dat

/bin/sed -i "/DB_USER/c\ define('DB_USER', \"${name}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database user credential" >> ${HOME}/logs/MonitoringLog.dat

/bin/sed -i "/DB_PASSWORD/c\ define('DB_PASSWORD', \"${password}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database password credential" >> ${HOME}/logs/MonitoringLog.dat

/bin/sed -i "/DB_NAME/c\ define('DB_NAME', \"${database}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database name" >> ${HOME}/logs/MonitoringLog.dat

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 

#Sort the salts and switch the cache on
if ( [ "`/bin/cat ${HOME}/runtime/wordpress_config.php | /bin/grep SALTEDALREADY`" = "" ] )
then
    /bin/sed -i "/'AUTH_KEY'/i XXYYZZ" ${HOME}/runtime/wordpress_config.php
    /bin/sed -i '/AUTH_KEY/,+7d' ${HOME}/runtime/wordpress_config.php
    salts="`/usr/bin/curl https://api.wordpress.org/secret-key/1.1/salt`"
    /bin/sed -n '/XXYYZZ/q;p' ${HOME}/runtime/wordpress_config.php > /tmp/firsthalf
    /bin/sed '0,/^XXYYZZ$/d' ${HOME}/runtime/wordpress_config.php > /tmp/secondhalf
    /bin/cat /tmp/firsthalf > /tmp/fullfile
    /bin/echo ${salts} >> /tmp/fullfile
    /bin/echo "/* SALTEDALREADY */" >> /tmp/fullfile
    /bin/echo "define('WP_CACHE', true);" >>/tmp/fullfile
    /bin/echo "define( 'DISALLOW_FILE_EDIT', true );" >> /tmp/fullfile
    /bin/echo "define( 'WPCACHEHOME', '/var/www/html/wp-content/plugins/wp-super-cache/' );" >> /tmp/fullfile     
    /bin/cat /tmp/secondhalf >> /tmp/fullfile
    /bin/rm /tmp/firsthalf /tmp/secondhalf
    /bin/mv /tmp/fullfile ${HOME}/runtime/wordpress_config.php
fi

if ( [ ! -d /var/www/html/wp-content/tmp ] )
then
    /bin/mkdir /var/www/html/wp-content/tmp
    /bin/chmod -R 755 /var/www/html/wp-content/tmp
    /bin/chown -R www-data.www-data /var/www/html/wp-content/tmp
fi

if ( [ ! -d /var/www/html/wp-content/logs ] )
then
    /bin/mkdir /var/www/html/wp-content/logs
    /bin/chmod -R 755 /var/www/html/wp-content/logs
    /bin/chown -R www-data.www-data /var/www/html/wp-content/logs
fi

if ( [ ! -d /var/www/html/wp-content/cache ] )
then
    /bin/mkdir /var/www/html/wp-content/cache
    /bin/chmod -R 755 /var/www/html/wp-content/cache
    /bin/chown -R www-data.www-data /var/www/html/wp-content/cache
fi

if ( [ -f ${HOME}/config/wordpress_config.php ] &&
    ( [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] ) &&
    ( [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${name}`" = "" ] ||
        [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${password}`" = "" ] ||
        [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${database}`" = "" ] ||
[ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${host}`" = "" ] ) )
then
    if ( [ -f /var/www/wp-config.php ] &&
    [ "`/usr/bin/diff ${HOME}/config/wordpress_config.php ${HOME}/runtime/wordpress_config.php`" != "" ] )
    then
        /bin/cp ${HOME}/runtime/wordpress_config.php  ${HOME}/config/wordpress_config.php
        /bin/cp ${HOME}/runtime/wordpress_config.php /var/www/wp-config.php
    fi
    count="0"
    while ( [ "${count}" -lt "5" ] && [ "`/usr/bin/diff ${HOME}/config/wordpress_config.php /var/www/wp-config.php`" != "" ] )
    do
        /bin/cp ${HOME}/runtime/wordpress_config.php  ${HOME}/config/wordpress_config.php
        count="`/usr/bin/expr ${count} + 1`"
        /bin/sleep 5
    done
    if ( [ "${count}" = "5" ] )
    then
        /bin/echo "${0} `/bin/date`: Failed to copy the configuration file successfully" >> ${HOME}/logs/MonitoringLog.dat
        exit
    fi

    /bin/chown www-data.www-data ${HOME}/config/wordpress_config.php
    /bin/chmod 640 ${HOME}/config/wordpress_config.php
fi

if ( [ -f ${HOME}/config/wordpress_config.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/config/APPLICATION_DB_CONFIGURED
else
    /bin/cp ${HOME}/runtime/wordpress_config.php ${HOME}/config/wordpress_config.php
fi


