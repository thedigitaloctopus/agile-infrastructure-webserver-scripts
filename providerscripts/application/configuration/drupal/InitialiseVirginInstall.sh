#!/bin/sh
#############################################################################
# Description: This script will initialise a virgin copy of drupal
# Author: Peter Winter
# Date: 04/01/2017
###############################################################################
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
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )

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

if ( [ -f /var/www/html/sites/default/settings.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/html/sites/default/settings.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat /var/www/html/sites/default/settings.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat /var/www/html/sites/default/settings.php | /bin/grep ${database}`" != "" ] &&
    [ "`/bin/cat /var/www/html/sites/default/settings.php | /bin/grep ${host}`" != "" ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/VIRGINCONFIGSET ] && [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

if ( [ ! -f ${HOME}/config/drupal_settings.php ] )
then
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
fi

if ( [ -f ${HOME}/config/drupal_settings.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${host}`" != "" ] )
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

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DB_PORT'`"

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

if ( [ -f /var/www/html/sites/default/default.settings.php ] )
then
    /bin/cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php.default
fi

if ( [ ! -f ${HOME}/runtime/drupal_settings.php ] )
then
    /bin/cp /var/www/html/sites/default/settings.php.default ${HOME}/runtime/drupal_settings.php
fi

if ( [ -f ${HOME}/config/drupal_settings.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
    exit
fi

/usr/bin/perl -i -pe 'BEGIN{undef $/;} s/^\$databases.\;/\$databases = [];/smg' ${HOME}/runtime/drupal_settings.php

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    # /bin/sed -i "/^\$databases.*;/c  \$databases['default']['default'] = array ( \\n 'database' => '${database}', \\n 'username' => '${username}', \\n 'password' => '${password}', \\n 'host' => '${host}', \\n 'port' => '${DB_PORT}', \\n 'driver' => 'pgsql', \\n 'prefix' => '${prefix}_', \\n 'collation' => 'utf8mb4_general_ci', \\n );" ${HOME}/runtime/drupal_settings.php
    credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${database}', \n 'username' => '${username}', \n 'password' => '${password}', \n 'host' => '${host}', \n 'port' => '${DB_PORT}', \n 'driver' => 'pgsql', \n 'prefix' => '${prefix}_', \n 'collation' => 'utf8mb4_general_ci',\n);"

else
    # /bin/sed -i "/^\$databases.*;/c  \$databases['default']['default'] = array ( \\n 'database' => '${database}', \\n 'username' => '${username}', \\n 'password' => '${password}', \\n 'host' => '${host}', \\n 'port' => '${DB_PORT}', \\n 'driver' => 'mysql', \\n 'prefix' => '${prefix}_', \\n 'collation' => 'utf8mb4_general_ci', \\n );" ${HOME}/runtime/drupal_settings.php
    credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${database}', \n 'username' => '${username}', \n 'password' => '${password}', \n 'host' => '${host}', \n 'port' => '${DB_PORT}', \n 'driver' => 'mysql', \n 'prefix' => '${prefix}_', \n 'collation' => 'utf8mb4_general_ci',\n);"

fi

/bin/sed -i "s/^\$databases = \[\]\;/${credentialstring}/" ${HOME}/runtime/drupal_settings.php

salt="`< /dev/urandom tr -dc a-z | head -c${1:-16};echo;`"
/bin/sed -i "/^\$settings\['hash_salt'\]/c\$settings['hash_salt'] = '${salt}';" ${HOME}/runtime/drupal_settings.php


###DEPRECATED
#if ( [ "`/bin/cat ${HOME}/runtime/drupal_settings.php | /bin/grep 'CONFIG_SYNC_DIRECTORY'`" = "" ] )
#then
#    /bin/echo "\$settings['trusted_host_patterns'] = [ '.*' ];" >> ${HOME}/runtime/drupal_settings.php
#
#    /bin/echo "\$config_directories = array(
#    CONFIG_SYNC_DIRECTORY => '/var/www/html/sites/default',
#    );" >> ${HOME}/runtime/drupal_settings.php
#fi

if ( [ "`/bin/cat ${HOME}/runtime/drupal_settings.php | /bin/grep 'ADDED BY CONFIG PROCESS'`" = "" ] )
then
    /bin/echo "#====ADDED BY CONFIG PROCESS=====" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$settings['trusted_host_patterns'] = [ '.*' ];" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$settings['config_sync_directory'] = '/var/www/html/sites/default';" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$config['system.performance']['css']['preprocess'] = FALSE;" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$config['system.performance']['js']['preprocess'] = FALSE;" >> ${HOME}/runtime/drupal_settings.php 
fi

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 
/bin/cp ${HOME}/runtime/drupal_settings.php ${HOME}/config/drupal_settings.php

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

/bin/chown www-data.www-data ${HOME}/config/drupal_settings.php
/bin/chmod 640 ${HOME}/config/drupal_settings.php


if ( [ -f ${HOME}/config/drupal_settings.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${host}`" != "" ] )
then
    /bin/mkdir -p /var/www/html/sites/default/files/pictures
    /bin/chown -R www-data.www-data /var/www/html/sites/default
    #We are ready to set up services and switch off twig caching
    if ( [ -f /var/www/html/sites/default/default.services.yml ] )
    then
        /bin/mv /var/www/html/sites/default/default.services.yml /var/www/html/sites/default/services.yml
        /bin/sed -i "s/cache: true/cache: false/g" /var/www/html/sites/default/services.yml
    fi
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
else
    /bin/cp ${HOME}/runtime/drupal_settings.php ${HOME}/config/drupal_settings.php
fi
