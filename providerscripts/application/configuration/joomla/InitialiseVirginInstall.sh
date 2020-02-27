#!/bin/sh
#############################################################################################
# Description: If your application requires any post processing to be performed,
# then, this is the place to put it. Post processing is considered to be any processing
# which is required after the application is considered installed. This is the post
# processing for a joomla install. If you examine the code, you will find that this
# script is called from the build client over ssh once it considers that the application
# has been fully installed.
# I decided not to support postgres with joomla because it's not very well supported itself
# and also there's some issues according to:
# https://joomla.stackexchange.com/questions/688/can-i-use-postgresql-with-joomla-3-3
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

#So, the scenarios are for where our database resides is as follows:
# 1) It is a DBaaS and it has been secured with an SSH tunnel. In this case, our hostname will be our local ip address
# 2) It is a DBaaS and it hasn't been secured with an SSH tunnel. In this case our hostname is the name of the database
# 3) We are running our own local database, and a local ip address is the address of the database
# Each deployment will have its own reason for chosing its own type of DB solution.
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
    host="`/bin/ls ${HOME}/config/databaseip`"
fi

username="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"
password="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
database="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"

if ( [ "${username}" = "" ] || [ "${password}" = "" ] || [ "${database}" = "" ] || [ "${host}" = "" ] )
then
    exit
fi

if ( [ -f /var/www/html/configuration.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/html/configuration.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat /var/www/html/configuration.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat /var/www/html/configuration.php | /bin/grep ${database}`" != "" ] &&
    [ "`/bin/cat /var/www/html/configuration.php | /bin/grep ${host}`" != "" ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/VIRGINCONFIGSET ] && [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

if ( [ ! -f ${HOME}/config/joomla_configuration.php ] )
then
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
fi

if ( [ -f ${HOME}/config/joomla_configuration.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${host}`" != "" ] )
then
    :
else
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
fi

#Get the port that the database is running on
DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

#Set a prefix for our database tables. Make sure we only ever set one in the case where the script runs more than once
#and exits for some reason.
if ( [ "`/bin/ls ${HOME}/.ssh/DBPREFIX:* 2>/dev/null`" = "" ] && [ ! -f /var/www/html/dpb.dat ] )
then
    prefix="`< /dev/urandom tr -dc a-z | head -c${1:-6};echo;`"
    /bin/touch ${HOME}/.ssh/DBPREFIX:${prefix}
    /bin/chown www-data.www-data ${HOME}/.ssh/DBPREFIX:*
    /bin/chmod 755 ${HOME}/.ssh/DBPREFIX:*
    /bin/echo "${prefix}" > /var/www/html/dpb.dat
else
    prefix="`/bin/cat /var/www/html/dpb.dat`"
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

#If we get to here, then we have all we need. This is a new or virgin application, so, we set the prefix for the
#database tables. This prefix will be used for the lifetime of the application
if ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] )
then
    /bin/sed -i "s/#__/${prefix}_/g" /var/www/html/installation/sql/mysql/joomla.sql
fi

#A default joomla download has a sample configuration.php file in its installation directory. What we can do is copy
#this file to be our main configuration.php file and modify it according to the credentials that have been set later on.
#These credentials will be modified by the script called ConfigureDBAccess.sh
if ( [ -f /var/www/html/installation/configuration.php-dist ] )
then
    /bin/cp /var/www/html/installation/configuration.php-dist /var/www/html/configuration.php.default
fi

#We also make our own default copy, because once the application is live, the configuration.php-dist is no longer about.
#When we backup our application to a repository, we nuke our configuration.php file for security reasons as it will
#contain credentials and so on, which could still be active. It's just making doubly sure. We can use our own default copy
#to generate our configuration.php when we are deploying an application which is no longer virginal and has been modified
#in a bespoke way
if ( [ ! -f ${HOME}/runtime/joomla_configuration.php ] )
then
    /bin/cp /var/www/html/configuration.php.default ${HOME}/runtime/joomla_configuration.php
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

if ( [ -f ${HOME}/config/joomla_configuration.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
    exit
fi

/bin/sed -i "/\$dbprefix /c\        public \$dbprefix = \'${prefix}_\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$user /c\        public \$user = \'${username}\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$password /c\        public \$password = \'${password}\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$db /c\        public \$db = \'${database}\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$host /c\        public \$host = \'${host}:${DB_PORT}\';" ${HOME}/runtime/joomla_configuration.php
secret="`< /dev/urandom tr -dc a-z | head -c${1:-16};echo;`"
/bin/touch ${HOME}/config/SECRET:${secret}
/bin/sed -i "/\$secret /c\        public \$secret = \'${secret}\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$cachetime /c\        public \$cachetime = \'30\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'${cache}\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$caching /c\        public \$caching = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'file\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$sef /c\        public \$sef = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$sef_suffix /c\        public \$sef_suffix = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$sef_rewrite /c\        public \$sef_rewrite = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$gzip /c\        public \$gzip = \'1\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$force_ssl /c\        public \$force_ssl = \'2\';" ${HOME}/runtime/joomla_configuration.php
/bin/echo "${0} `/bin/date`: Updating the force ssl" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i "/\$tmp_path /c\        public \$tmp_path = \'/var/www/html/tmp\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$log_path /c\        public \$log_path = \'/var/www/html/logs\';" ${HOME}/runtime/joomla_configuration.php
/bin/sed -i "/\$shared_session /c\        public \$shared_session = \'1\';" ${HOME}/runtime/joomla_configuration.php

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


if ( [ -f ${HOME}/config/joomla_configuration.php ] &&
    ( [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] ) &&
    ( [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${username}`" = "" ] ||
        [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${password}`" = "" ] ||
        [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${database}`" = "" ] ||
[ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${host}`" = "" ] ) )
then
    if ( [ -f /var/www/html/configuration.php ] &&
    [ "`/usr/bin/diff ${HOME}/config/joomla_configuration.php ${HOME}/runtime/joomla_configuration.php`" != "" ] )
    then
        /bin/cp ${HOME}/runtime/joomla_configuration.php  ${HOME}/config/joomla_configuration.php
        /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
    fi
    count="0"
    while ( [ "${count}" -lt "5" ] && [ "`/usr/bin/diff ${HOME}/config/joomla_configuration.php ${HOME}/runtime/joomla_configuration.php`" != "" ] )
    do
        /bin/cp ${HOME}/runtime/joomla_configuration.php  ${HOME}/config/joomla_configuration.php
        /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
        count="`/usr/bin/expr ${count} + 1`"
        /bin/sleep 5
    done
    if ( [ "${count}" = "5" ] )
    then
        /bin/echo "${0} `/bin/date`: Failed to copy the configuration file successfully" >> ${HOME}/logs/MonitoringLog.dat
        exit
    fi
    /bin/chown www-data.www-data ${HOME}/config/joomla_configuration.php
    /bin/chmod 640 ${HOME}/config/joomla_configuration.php
fi

if ( [ -f ${HOME}/config/joomla_configuration.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/joomla_configuration.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
else
    /bin/cp ${HOME}/runtime/joomla_configuration.php ${HOME}/config/joomla_configuration.php
fi


