#!/bin/sh
###############################################################################
# Description: This script will initialise a virgin copy of wordpress
# Author: Peter Winter
# Date: 04/01/2017
################################################################################
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
###################################################################################
###################################################################################
#set -x

#So, the scenarios are for where our database resides is as follows:
# 1) It is a DBaaS and it has been secured with an SSH tunnel. In this case, our hostname will be our local ip address
# 2) It is a DBaaS and it hasn't been secured with an SSH tunnel. In this case our hostname is the name of the database
# 3) We are running our own local database, and a local ip address is the address of the database
# Each deployment will have it's own reason for chosing it's own type of DB solution.
if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    if ( [ ! -f  ${HOME}/runtime/SSHTUNNELCONFIGURED ] )
    then
        exit
    fi
    host="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    host="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    if ( [ "`/bin/ls ${HOME}/config/databaseip/`" = "" ] )
    then
        exit
    fi
    host="`/bin/ls ${HOME}/config/databaseip | /usr/bin/head -1`"
fi

username="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"
password="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
database="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"

if ( [ "${username}" = "" ] || [ "${password}" = "" ] || [ "${database}" = "" ] || [ "${host}" = "" ] )
then
    exit
fi

if ( [ -f /var/www/wp-config.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${database}`" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${host}`" != "" ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/VIRGINCONFIGSET ] && [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

if ( [ ! -f ${HOME}/config/wordpress_config.php ] )
then
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
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

if ( [ -f ${HOME}/config/wordpress_config.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${host}`" != "" ] )
then
    :
else
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
fi

#If our configuration is already set, then, we don't need to do diddly
if ( [ -f ${HOME}/runtime/VIRGINCONFIGSET ] )
then
    exit
fi

#If the application configuration arrangements haven't been made, we are not ready, so just exit
if ( [ ! -f ${HOME}/config/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

#Once an application is considered to be installed, then, a flag is set which means that on subsequent calls
#we do nothing. This is because this script is aggressively called from cron until it succeeds and once it is
#successful, we need to neutralise it. Also, if we are not a virgin, then we can't do this so exit.
#Note, please check crontab and you will find that there this script is called every minute which is what I mean
#by aggressive.

if ( [ ! -f ${HOME}/.ssh/BUILDARCHIVECHOICE:virgin ] )
then
    exit
fi

#Check that the config directory mounted successfully and that the credentials are available, if not wait till next time
#as they might be by then
if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] || [ ! -f ${HOME}/config/credentials/shit ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/wordpress_config.php ] && [ ! -f ${HOME}/config/wordpress_config.php ] )
then
    /bin/cp ${HOME}/runtime/wordpress_config.php ${HOME}/config/wordpress_config.php
fi

DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ -f /var/www/html/wp-config-sample.php ] )
then
    /bin/cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php.default
fi

if ( [ ! -f ${HOME}/runtime/wordpress_config.php ] )
then
    /bin/cp /var/www/html/wp-config.php.default ${HOME}/runtime/wordpress_config.php
fi

if ( [ "`/bin/cat /var/www/html/index.php | /bin/grep session_save_path`" = "" ] )
then
    /bin/sed -i '1 s/^.*$/<?php \nsession_save_path \(\"\/var\/www\/html\/wp-content\/uploads\/\"\);/' /var/www/html/index.php
fi

if ( [ -f ${HOME}/config/wordpress_config.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
    exit
fi

/bin/sed -i "/DB_HOST/c\ define('DB_HOST', \"${host}:${DB_PORT}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/DB_USER/c\ define('DB_USER', \"${username}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/DB_PASSWORD/c\ define('DB_PASSWORD', \"${password}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/DB_NAME/c\ define('DB_NAME', \"${database}\");" ${HOME}/runtime/wordpress_config.php

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
    /bin/echo "define('WP_CACHE', true);" >> /tmp/fullfile
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
    ( [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] ) &&
    ( [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${username}`" = "" ] ||
        [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${password}`" = "" ] ||
        [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${database}`" = "" ] ||
[ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${host}`" = "" ] ) )
then
    if ( [ -f /var/www/wp-config.php ] &&
    [ "`/usr/bin/diff ${HOME}/config/wordpress_config.php ${HOME}/runtime/wordpress_config.php`" != "" ] )
    then
        /bin/cp ${HOME}/runtime/wordpress_config.php ${HOME}/config/wordpress_config.php
        /bin/cp ${HOME}/runtime/wordpress_config.php /var/www/wp-config.php
    fi

    count="0"
    while ( [ "${count}" -lt "5" ] && [ "`/usr/bin/diff ${HOME}/config/wordpress_config.php ${HOME}/runtime/wordpress_config.php`" != "" ] )
    do
        /bin/cp ${HOME}/runtime/wordpress_config.php ${HOME}/config/wordpress_config.php
        /bin/cp ${HOME}/runtime/wordpress_config.php /var/www/html/wp-config.php
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
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/wordpress_config.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
else
    /bin/cp ${HOME}/runtime/wordpress_config.php ${HOME}/config/wordpress_config.php
fi
fi
