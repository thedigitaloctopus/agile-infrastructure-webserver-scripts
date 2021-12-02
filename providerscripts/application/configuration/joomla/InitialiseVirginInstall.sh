#!/bin/sh
#############################################################################################
# Description: If your application requires any post processing to be performed,
# then, this is the place to put it. Post processing is considered to be any processing
# which is required after the application is considered installed. This is the post
# processing for a joomla install. If you examine the code, you will find that this
# script is called from the build client over ssh once it considers that the application
# has been fully installed.
# Author: Peter Winter
# Date: 04/01/2017
#############################################################################################
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
##########################################################################################
##########################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    if ( [ "`/bin/ls ${HOME}/config/databaseip/`" = "" ] )
    then
        exit
    fi
    host="`/bin/ls ${HOME}/config/databaseip`"
fi

username="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"
password="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
database="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"

if ( [ "${username}" = "" ] || [ "${password}" = "" ] || [ "${database}" = "" ] || [ "${host}" = "" ] )
then
    exit
fi

if ( ( [ -f /var/www/html/configuration.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${username} /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep ${password} /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep ${database} /var/www/html/configuration.php`" != "" ] &&
    [ "`/bin/grep ${host} /var/www/html/configuration.php`" != "" ] ) )
then
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
    exit
else
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
fi

#Get the port that the database is running on
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

#If the application configuration arrangements haven't been made, we are not ready, so just exit
if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/joomla-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
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
if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] || [ ! -f ${HOME}/config/credentials/shit ] )
then
    exit
fi

#If we get to here, then we have all we need. This is a new or virgin application, so, we set the prefix for the
#database tables. This prefix will be used for the lifetime of the application
#if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
#then
#    #joomla 3 -
#    /bin/sed -i "s/#__/${prefix}_/g" /var/www/html/installation/sql/mysql/joomla.sql
#    #joomla 4 +
#    /bin/sed -i "s/#__/${prefix}_/g" /var/www/html/installation/sql/mysql/base.sql
#    /bin/sed -i "s/#__/${prefix}_/g" /var/www/html/installation/sql/mysql/extensions.sql
#    /bin/sed -i "s/#__/${prefix}_/g" /var/www/html/installation/sql/mysql/supports.sql
#fi

#if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
#then
#    #joomla 3 -
#    /bin/sed -i "s/#__/${prefix}_/g" /var/www/html/installation/sql/postgresql/joomla.sql
#    #joomla 4 +
#    /bin/sed -i "s/#__/${prefix}_/g" /var/www/html/installation/sql/postgresql/base.sql
#    /bin/sed -i "s/#__/${prefix}_/g" /var/www/html/installation/sql/postgresql/extensions.sql
#    /bin/sed -i "s/#__/${prefix}_/g" /var/www/html/installation/sql/postgresql/supports.sql
#fi

/bin/sed -i "/\$dbprefix /c\        public \$dbprefix = \'${prefix}_\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$user /c\        public \$user = \'${username}\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$password /c\        public \$password = \'${password}\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$db /c\        public \$db = \'${database}\';" ${HOME}/runtime/joomla_configuration.php

dbipandport="${host}:${DB_PORT}"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'pgsql\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "For your information, this website uses Postgres" > /var/www/html/dbe.dat
    /bin/sed -i "/\$port /d" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$host /c\        public \$host = \'${host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$host /a        public \$port = \'${DB_PORT}\';" ${HOME}/runtime/joomla_configuration.php
else
    /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'mysqli\';" ${HOME}/runtime/joomla_configuration.php
    /bin/echo "For your information, this website uses MySQL or MariaDB" > /var/www/html/dbe.dat
    /bin/sed -i "/\$host = /c\   public \$host = \'${dbipandport}\';" ${HOME}/runtime/joomla_configuration.php
fi

secret="`/bin/ls ${HOME}/config/SECRET:* | /usr/bin/awk -F':' '{print $NF}' 2>/dev/null`"
if ( [ "${secret}" = "" ] )
then
    secret="`/bin/cat /dev/urandom | /usr/bin/tr -dc a-z | /usr/bin/head -c${1:-16};echo;`"
    /bin/touch ${HOME}/config/SECRET:${secret}
fi

/bin/sed -i "/\$secret /c\        public \$secret = \'${secret}\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$cachetime /c\        public \$cachetime = \'30\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'${cache}\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$caching /c\        public \$caching = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'file\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$sef /c\        public \$sef = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$sef_suffix /c\        public \$sef_suffix = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$sef_rewrite /c\        public \$sef_rewrite = \'0\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$gzip /c\        public \$gzip = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$force_ssl /c\        public \$force_ssl = \'2\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the force ssl" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$tmp_path /c\        public \$tmp_path = \'/var/www/html/tmp\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$log_path /c\        public \$log_path = \'/var/www/html/logs\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$shared_session /c\        public \$shared_session = \'0\';" ${HOME}/runtime/joomla_configuration.php

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh INMEMORYCACHING:memcache`" = "1" ] )
then
    /bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'memcache\';" ${HOME}/runtime/joomla_configuration.php
    cache_host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGHOST'`"
    cache_port="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGHOST'`"
    /bin/sed -i "/\$memcache_server_host /c\        public \$memcache_server_host = \'${cache_host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$memcache_server_port /c\        public \$memcache_server_port = \'${cache_port}\';" ${HOME}/runtime/joomla_configuration.php
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh INMEMORYCACHING:redis`" = "1" ] )
then
    /bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'redis\';" ${HOME}/runtime/joomla_configuration.php
    cache_host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGHOST'`"
    cache_port="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INMEMORYCACHINGHOST'`"
    /bin/sed -i "/\$redis_server_host /c\        public \$redis_server_host = \'${cache_host}\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$redis_server_port /c\        public \$redis_server_port = \'${cache_port}\';" ${HOME}/runtime/joomla_configuration.php
fi

#The temp directories for joomla can be set. They should exist already, but why the hell not make sure.
if ( [ ! -d /var/www/html/cache ] )
then
    /bin/mkdir /var/www/html/cache
    /bin/chmod 755 /var/www/html/cache
    /bin/chown -R www-data.www-data /var/www/html/cache
fi

if ( [ ! -d /var/www/html/tmp ] )
then
    /bin/mkdir /var/www/html/tmp
    /bin/chmod 755 /var/www/html/tmp
    /bin/chown -R www-data.www-data /var/www/html/tmp
fi

if ( [ ! -d /var/www/html/logs ] )
then
    /bin/mkdir /var/www/html/logs
    /bin/chmod -R 755 /var/www/html/logs
    /bin/chown -R www-data.www-data /var/www/html/logs
fi

if ( [ -f /var/www/html/cli/garbagecron.php ] )
then
    /usr/bin/php /var/www/html/cli/garbagecron.php
fi
