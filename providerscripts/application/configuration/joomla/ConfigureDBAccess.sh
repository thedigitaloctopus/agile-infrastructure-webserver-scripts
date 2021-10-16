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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    host="${dbip}"
fi

if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ]  )
then
    exit
fi

if ( [ -f /var/www/html/configuration.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${name} /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep ${password} /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep ${database} /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep ${host} /var/www/html/configuration.php`" != "" ] )
then
    /bin/touch ${HOME}/runtime/APPLICATION_DB_CONFIGURED
    exit
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
fi

#Set the credentials that we need
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
dbipandport="${host}:${DB_PORT}"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'pgsql\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating the database driver" >> ${HOME}/logs/MonitoringLog.dat
    /bin/sed -i "/\$port /d" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$host /c\        public \$host = \'${host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$host /a        public \$port = \'${DB_PORT}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating the database ip" >> ${HOME}/logs/MonitoringLog.dat
else
    /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'mysqli\';" ${HOME}/runtime/joomla_configuration.php
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

dbprefix="`/bin/cat /var/www/html/dpb.dat`"
if ( [ "${dbprefix}" != "" ] && [ ! -f ${HOME}/config/UPDATEDPREFIX ] )
then
    /bin/sed -i "/\$dbprefix /c\        public \$dbprefix = \'${dbprefix}_\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating the database prefix" >> ${HOME}/logs/MonitoringLog.dat
    /bin/touch ${HOME}/config/UPDATEDPREFIX:${dbprefix}
fi

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

if ( [ -f ${HOME}/config/joomla_configuration.php ] )
then
    secret="`/bin/ls ${HOME}/config/SECRET:* | /usr/bin/awk -F':' '{print $NF}' 2>/dev/null`"

    if ( [ "${secret}" = "" ] )
    then
        secret="`/bin/cat /dev/urandom | /usr/bin/tr -dc a-z | /usr/bin/head -c${1:-16};echo;`"
        /bin/touch ${HOME}/config/SECRET:${secret}
    fi

    /bin/sed -i "/\$secret /c\        public \$secret = \'${secret}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating secret" >> ${HOME}/logs/MonitoringLog.dat
   # /bin/cp ${HOME}/runtime/joomla_configuration.php ${HOME}/config/joomla_configuration.php
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
