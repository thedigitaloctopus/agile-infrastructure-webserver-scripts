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

#Check that we have a prefix available, there must be an existing and well known prefix
dbprefix="`/bin/cat /var/www/html/dbp.dat`"
if ( [ "${dbprefix}" = "" ] )
then
    dbprefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*`"
fi
if ( [ "${dbprefix}" = "" ] )
then
    exit
fi
if ( [ "`/bin/grep ${dbprefix} ${HOME}/runtime/wordpress_config.php`" = "" ] )
then
    /bin/sed -i "/\$table_prefix/c\ \$table_prefix=\"${dbprefix}_\";" ${HOME}/runtime/wordpress_config.php
    /bin/touch ${HOME}/runtime/wordpress_config.php
    /bin/echo "${0} `/bin/date`: Updating the database prefix" >> ${HOME}/logs/MonitoringLog.dat
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*`" != "" ] )
    then
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "DBPREFIX:*"
    fi
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh DBPREFIX:${dbprefix}    
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    host="${dbip}"
fi

if ( [ -f /var/www/wp-config.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${name} /var/www/wp-config.php`" != "" ] &&
    [ "`/bin/grep ${password} /var/www/wp-config.php`" != "" ] &&
    [ "`/bin/grep ${database} /var/www/wp-config.php`" != "" ] &&
    [ "`/bin/grep ${host} /var/www/wp-config.php`" != "" ] )
then
    if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
    then
        /bin/echo " " >> ${HOME}/runtime/wordpress_config.php
    fi
    /bin/touch ${HOME}/runtime/APPLICATION_DB_CONFIGURED
    exit
else
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] && [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ]  )
then
    exit
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/wordpress-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
    exit
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    database="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    password="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    name="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
fi

/bin/sed -i "/DB_HOST/c\ define('DB_HOST', \"${host}:${DB_PORT}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database host name" >> ${HOME}/logs/MonitoringLog.dat

/bin/sed -i "/DB_USER/c\ define('DB_USER', \"${name}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database user credential" >> ${HOME}/logs/MonitoringLog.dat

/bin/sed -i "/DB_PASSWORD/c\ define('DB_PASSWORD', \"${password}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database password credential" >> ${HOME}/logs/MonitoringLog.dat

/bin/sed -i "/DB_NAME/c\ define('DB_NAME', \"${database}\");" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database name" >> ${HOME}/logs/MonitoringLog.dat

/bin/sed -i "/\$table_prefix/c\ \$table_prefix=\"${dbprefix}_\";" ${HOME}/runtime/wordpress_config.php
/bin/echo "${0} `/bin/date`: Updating the database table prefix" >> ${HOME}/logs/MonitoringLog.dat

/bin/echo "For your information, this website uses MySQL or MariaDB" > /var/www/html/dbe.dat

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 

#Sort the salts and switch the cache on
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
