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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*`" = "" ] )
    then
        exit
    fi
    host="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/* | /usr/bin/head -1`"
fi

database="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
password="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
username="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

if ( [ "${username}" = "" ] || [ "${password}" = "" ] || [ "${database}" = "" ] || [ "${host}" = "" ] )
then
    exit
fi

if ( ( [ -f /var/www/wp-config.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${username} /var/www/wp-config.php`" != "" ] &&
    [ "`/bin/grep ${password} /var/www/wp-config.php`" != "" ] &&
    [ "`/bin/grep ${database} /var/www/wp-config.php`" != "" ] &&
    [ "`/bin/grep ${host} /var/www/wp-config.php`" != "" ] ) )
then
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
    exit
else
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

#Set a prefix for our database tables. Make sure we only ever set one in the case where the script runs more than once
#and exits for some reason.
if ( [ ! -f /var/www/html/dbp.dat ] )
then
    prefix="`/bin/cat /dev/urandom | /usr/bin/tr -dc a-z | /usr/bin/head -c${1:-6};echo;`"
    if ( [ "${prefix}" != "" ] )
    then
        ${HOME}/providerscripts/utilities/StoreConfigValue.sh "DBPREFIX" "${prefix}"
        /bin/echo "${prefix}" > /var/www/html/dbp.dat
    fi
else
    prefix="`/bin/cat /var/www/html/dbp.dat`"
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/wordpress-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
fi

#If the application configuration arrangements haven't been made, we are not ready, so just exit
if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

#Once an application is considered to be installed, then, a flag is set which means that on subsequent calls
#we do nothing. This is because this script is aggressively called from cron until it succeeds and once it is
#successful, we need to neutralise it. Also, if we are not a virgin, then we can't do this so exit.
#Note, please check crontab and you will find that there this script is called every minute which is what I mean
#by aggressive.

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] )
then
    exit
fi

#Check that the config directory mounted successfully and that the credentials are available, if not wait till next time
#as they might be by then
#if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] || [ ! -f ${HOME}/config/credentials/shit ] )
#then
#    exit
#fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
   exit
fi

if ( [ -f ${HOME}/runtime/wordpress_config.php ] && [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "wordpress_config.php"`" = "0" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/wordpress_config.php ${HOME}/config/wordpress_config.php
fi

/bin/sed -i "/DB_HOST/c\ define('DB_HOST', \"${host}:${DB_PORT}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/DB_USER/c\ define('DB_USER', \"${username}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/DB_PASSWORD/c\ define('DB_PASSWORD', \"${password}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/DB_NAME/c\ define('DB_NAME', \"${database}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/\$table_prefix/c\ \$table_prefix=\"${prefix}_\";" ${HOME}/runtime/wordpress_config.php
/bin/echo "For your information, this website uses MySQL or MariaDB" > /var/www/html/dbe.dat


WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 

if ( [ "`/bin/grep SALTEDALREADY ${HOME}/runtime/wordpress_config.php`" = "" ] )
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
