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
    host="${dbip}"
fi

if ( [ -f /var/www/html/configuration.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/html/configuration.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat /var/www/html/configuration.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat /var/www/html/configuration.php | /bin/grep ${database}`" != "" ] &&
    [ "`/bin/cat /var/www/html/configuration.php | /bin/grep ${host}`" != "" ] )
then
    exit
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/joomla-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
fi

if ( [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

if ( [ ! -f ${HOME}/config/joomla_configuration.php ] )
then
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/config/joomla_configuration.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${host}`" != "" ] )
then
    :
else
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ ! -f ${HOME}/runtime/joomla_configuration.php ] )
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

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    database="`/bin/ls ${HOME}/.ssh/DBaaSDBNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
    password="`/bin/ls ${HOME}/.ssh/DBaaSPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
    name="`/bin/ls ${HOME}/.ssh/DBaaSUSERNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
fi

if ( [ ! -f ${HOME}/config/joomla_configuration.php ] )
then
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/config/joomla_configuration.php ] &&
    [ -f ${HOME}/config/APPLICATION_DB_CONFIGURED ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/config/APPLICATION_DB_CONFIGURED
    exit
else
    #I had some trouble using set directly on a shared/mounted from the datastore filesystem, so I make a copy, work on it and then
    #copy it to the shared filesystem for use in the real

    /bin/rm ${HOME}/runtime/joomla_configuration.php
    /bin/cp /var/www/html/configuration.php.default ${HOME}/runtime/joomla_configuration.php
fi

#This file enables us to detect which configuration file has been set from elsewhere if we are not sure
/bin/touch ${HOME}/.ssh/CONFIGFILE:joomla_configuration.php

#Set the credentials that we need
DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"
#currenthoststring="`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep '\$host'`"
#currentip="`/bin/echo ${currenthoststring} | /bin/grep -o "'.*'" | /bin/sed "s/'//g" | /bin/sed "s/:${DB_PORT}//g"`"
dbipandport="${host}:${DB_PORT}"

/bin/sed -i "/\$host = /c\   public \$host = \'${dbipandport}\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the database ip" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$dbtype /c\    public \$dbtype = \'mysqli\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the database driver" >> ${HOME}/logs/MonitoringLog.dat
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
/bin/sed -i "/\$sef /c\        public \$sef = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the sef" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$sef_suffix /c\        public \$sef_suffix = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the sef_suffix" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$sef_rewrite /c\        public \$sef_rewrite = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the sef_rewrite" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$gzip /c\        public \$gzip = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the gzip" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$force_ssl /c\        public \$force_ssl = \'2\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the force ssl" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$shared_session /c\        public \$shared_session = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating shared session" >> ${HOME}/logs/MonitoringLog.dat

dbprefix="`/bin/cat /var/www/html/dpb.dat`"
if ( [ "${dbprefix}" != "" ] && [ ! -f ${HOME}/config/UPDATEDPREFIX ] )
then
    /bin/sed -i "/\$dbprefix /c\        public \$dbprefix = \'${dbprefix}_\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating the database prefix" >> ${HOME}/logs/MonitoringLog.dat
    /bin/touch ${HOME}/config/UPDATEDPREFIX:${dbprefix}
fi

if ( [ -f ${HOME}/.ssh/INMEMORYCACHING:memcache ] )
then
    /bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'memcache\';" ${HOME}/runtime/joomla_configuration.php
    cache_host="`/bin/ls ${HOME}/.ssh/INMEMORYCACHINGHOST:* | /usr/bin/awk -F':' '{print $NF}'`"
    cache_port="`/bin/ls ${HOME}/.ssh/INMEMORYCACHINGPORT:* | /usr/bin/awk -F':' '{print $NF}'`"
    /bin/sed -i "/\$memcache_server_host /c\        public \$memcache_server_host = \'${cache_host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$memcache_server_port /c\        public \$memcache_server_port = \'${cache_port}\';" ${HOME}/runtime/joomla_configuration.php
fi

if ( [ -f ${HOME}/.ssh/INMEMORYCACHING:redis ] )
then
    /bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'redis\';" ${HOME}/runtime/joomla_configuration.php
    cache_host="`/bin/ls ${HOME}/.ssh/INMEMORYCACHINGHOST:* | /usr/bin/awk -F':' '{print $NF}'`"
    cache_port="`/bin/ls ${HOME}/.ssh/INMEMORYCACHINGPORT:* | /usr/bin/awk -F':' '{print $NF}'`"
    /bin/sed -i "/\$redis_server_host /c\        public \$redis_server_host = \'${cache_host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$redis_server_port /c\        public \$redis_server_port = \'${cache_port}\';" ${HOME}/runtime/joomla_configuration.php
fi

if ( [ -f ${HOME}/config/joomla_configuration.php ] )
then
    secret="`/bin/ls ${HOME}/config/SECRET:* | /usr/bin/awk -F':' '{print $NF}' 2>/dev/null`"

    if ( [ "${secret}" = "" ] )
    then
        secret="`< /dev/urandom tr -dc a-z | head -c${1:-16};echo;`"
        /bin/touch ${HOME}/config/SECRET:${secret}
    fi

    /bin/sed -i "/\$secret /c\        public \$secret = \'${secret}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "${0} `/bin/date`: Updating secret" >> ${HOME}/logs/MonitoringLog.dat
    /bin/cp ${HOME}/runtime/joomla_configuration.php ${HOME}/config/joomla_configuration.php
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


/usr/bin/rsync -au ${HOME}/runtime/joomla_configuration.php  ${HOME}/config/joomla_configuration.php
/usr/bin/rsync -au ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
/bin/chown www-data.www-data ${HOME}/config/joomla_configuration.php
/bin/chmod 640 ${HOME}/config/joomla_configuration.php
/bin/chown www-data.www-data /var/www/html/configuration.php
/bin/chmod 640 /var/www/html/configuration.php

if ( [ -f ${HOME}/config/joomla_configuration.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/config/APPLICATION_DB_CONFIGURED
else
    /bin/cp ${HOME}/runtime/joomla_configuration.php ${HOME}/config/joomla_configuration.php
fi

/usr/bin/php /var/www/html/cli/garbagecron.php



