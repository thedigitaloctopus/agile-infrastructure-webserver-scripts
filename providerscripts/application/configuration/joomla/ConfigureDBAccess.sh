#!/bin/sh
##################################################################################
# Description: This script will update update the database credentials for joomla
# Author: Peter Winter
# Date: 05/01/2017
##################################################################################
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
#################################################################################
#################################################################################
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
if ( [ "`/bin/grep ${dbprefix} ${HOME}/runtime/joomla_configuration.php`" = "" ] )
then
    /bin/sed -i "/\$dbprefix /c\        public \$dbprefix = \'${dbprefix}_\';" ${HOME}/runtime/joomla_configuration.php
    /bin/touch ${HOME}/runtime/joomla_configuration.php
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

if ( [ -f /var/www/html/configuration.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${name} /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep ${password} /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep ${database} /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep ${host} /var/www/html/configuration.php`" != "" ] )
then
    if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
    then
        /bin/echo " " >> ${HOME}/runtime/joomla_configuration.php
    fi
    /bin/touch ${HOME}/runtime/APPLICATION_DB_CONFIGURED
    exit
else
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] &&  [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ] )
then
    exit
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/joomla-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    database="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    password="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    name="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
fi

#Set the credentials that we need
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
dbipandport="${host}:${DB_PORT}"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'pgsql\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "For your information, this website uses Postgres" > /var/www/html/dbe.dat
    /bin/echo "${0} `/bin/date`: Updating the database driver" >> ${HOME}/logs/MonitoringLog.dat
    /bin/sed -i "/\$port /d" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$host /c\        public \$host = \'${host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$host /a        public \$port = \'${DB_PORT}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating the database ip" >> ${HOME}/logs/MonitoringLog.dat
else
    /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'mysqli\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "For your information, this website uses MySQL or MariaDB" > /var/www/html/dbe.dat
    /bin/echo "${0} `/bin/date`: Updating the database driver" >> ${HOME}/logs/MonitoringLog.dat
    /bin/sed -i "/\$host = /c\   public \$host = \'${dbipandport}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating the database ip" >> ${HOME}/logs/MonitoringLog.dat
fi

/bin/sed -i "/\$user/c\       public \$user = \'${name}\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the database user credential" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$password/c\   public \$password = \'${password}\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the database password credential" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$db /c\        public \$db = \'${database}\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the database name credential" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$cachetime /c\        public \$cachetime = \'30\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the cache expiration time" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'file\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the cache handler" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$caching /c\        public \$caching = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the caching" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$sef /c\        public \$sef = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the sef" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$sef_suffix /c\        public \$sef_suffix = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the sef_suffix" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$sef_rewrite /c\        public \$sef_rewrite = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the sef_rewrite" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$gzip /c\        public \$gzip = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the gzip" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$force_ssl /c\        public \$force_ssl = \'2\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the force ssl" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$shared_session /c\        public \$shared_session = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating shared session" >> ${HOME}/logs/MonitoringLog.dat

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh INMEMORYCACHING:memcache`" = "1" ] )
then
    /bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'memcache\';" ${HOME}/runtime/joomla_configuration.php
    cache_host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGHOST'`"
    cache_port="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGPORT'`"
    /bin/sed -i "/\$memcache_server_host /c\        public \$memcache_server_host = \'${cache_host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$memcache_server_port /c\        public \$memcache_server_port = \'${cache_port}\';" ${HOME}/runtime/joomla_configuration.php
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh INMEMORYCACHING:redis`" = "1" ] )
then
    /bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'redis\';" ${HOME}/runtime/joomla_configuration.php
    cache_host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGHOST'`"
    cache_port="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGPORT'`"
    /bin/sed -i "/\$redis_server_host /c\        public \$redis_server_host = \'${cache_host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$redis_server_port /c\        public \$redis_server_port = \'${cache_port}\';" ${HOME}/runtime/joomla_configuration.php
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "joomla_configuration.php"`" = "1" ] )
then
    secret="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh SECRET:*  | /usr/bin/awk -F':' '{print $NF}'`"

    if ( [ "${secret}" = "" ] )
    then
        secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh SECRET:${secret}    
    fi

    /bin/sed -i "/\$secret /c\        public \$secret = \'${secret}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating secret" >> ${HOME}/logs/MonitoringLog.dat
fi

#The temp directories for joomla can be set. They should exist already, but why the hell not make sure.
if ( [ ! -d /var/www/html/cache ] )
then
    /bin/mkdir /var/www/html/cache
    /bin/chown www-data.www-data /var/www/html/cache
    /bin/chmod 755 /var/www/html/cache
fi

if ( [ ! -d /var/www/html/administator/cache ] )
then
    /bin/mkdir /var/www/html/administrator/cache
    /bin/chown www-data.www-data /var/www/html/administrator/cache
    /bin/chmod 755 /var/www/html/administrator/cache
fi

if ( [ ! -d /var/www/html/tmp ] )
then
    /bin/mkdir /var/www/html/tmp
    /bin/chown www-data.www-data /var/www/html/tmp
    /bin/chmod 755 /var/www/html/tmp
fi

if ( [ ! -d /var/www/html/logs ] )
then
    /bin/mkdir /var/www/html/logs
    /bin/chown www-data.www-data /var/www/html/logs
    /bin/chmod 755 /var/www/html/logs
fi

/bin/sed -i "/\$tmp_path /c\        public \$tmp_path = \'/var/www/html/tmp\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$log_path /c\        public \$log_path = \'/var/www/html/logs\';" ${HOME}/runtime/joomla_configuration.php


if ( [ -f /var/www/html/cli/garbagecron.php ] )
then
    /usr/bin/php /var/www/html/cli/garbagecron.php
fi
