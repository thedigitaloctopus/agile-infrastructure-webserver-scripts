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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*`" = "" ] )
    then
        exit
    fi
    host="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*`"
fi

database="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
password="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
username="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

if ( [ "${username}" = "" ] || [ "${password}" = "" ] || [ "${database}" = "" ] || [ "${host}" = "" ] )
then
    exit
fi

if ( ( [ -f /var/www/html/sites/default/settings.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${username} /var/www/html/sites/default/settings.php`" != "" ] &&
    [ "`/bin/grep ${password} /var/www/html/sites/default/settings.php`" != "" ] &&
    [ "`/bin/grep ${database} /var/www/html/sites/default/settings.php`" != "" ] &&
    [ "`/bin/grep ${host} /var/www/html/sites/default/settings.php`" != "" ] ) )
then
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
    exit
else
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh drupal_settings.php`" = "0" ] )
then
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

#If the application configuration arrangements haven't been made, we are not ready, so just exit
if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/drupal-htaccess.txt /var/www/html/.htaccess
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
#if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] || [ ! -f ${HOME}/config/credentials/shit ] )
#then
#    exit
#fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
    exit
fi

/usr/bin/perl -i -pe 'BEGIN{undef $/;} s/^\$databases.\;/\$databases = [];/smg' ${HOME}/runtime/drupal_settings.php

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${database}', \n 'username' => '${username}', \n 'password' => '${password}', \n 'host' => '${host}', \n 'port' => '${DB_PORT}', \n 'driver' => 'pgsql', \n 'prefix' => '${prefix}_', \n 'collation' => 'utf8mb4_general_ci',\n);"
    /bin/echo "For your information, this website uses Postgres" > /var/www/html/dbe.dat
else
    credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${database}', \n 'username' => '${username}', \n 'password' => '${password}', \n 'host' => '${host}', \n 'port' => '${DB_PORT}', \n 'driver' => 'mysql', \n 'prefix' => '${prefix}_', \n 'collation' => 'utf8mb4_general_ci',\n);"
    /bin/echo "For your information, this website uses MySQL or MariaDB" > /var/www/html/dbe.dat
fi

/bin/sed -i "s/^\$databases = \[\]\;/${credentialstring}/" ${HOME}/runtime/drupal_settings.php

salt="`/bin/cat /dev/urandom | /usr/bin/tr -dc a-z | /usr/bin/head -c${1:-16};echo;`"
/bin/sed -i "/^\$settings\['hash_salt'\]/c\$settings['hash_salt'] = '${salt}';" ${HOME}/runtime/drupal_settings.php

if ( [ "`/bin/grep 'ADDED BY CONFIG PROCESS' ${HOME}/runtime/drupal_settings.php`" = "" ] )
then
    /bin/echo "#====ADDED BY CONFIG PROCESS=====" >> ${HOME}/runtime/drupal_settings.php
    /bin/mkdir /var/www/private
    /bin/chown www-data.www-data /var/www/private
    /bin/chmod 755 /var/www/private
    /bin/sed -i "s/.*file_private_path.*/ \$settings[\'file_private_path\'] = \'\/var\/www\/private\';/g" ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$settings['trusted_host_patterns'] = [ '.*' ];" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$settings['config_sync_directory'] = '/var/www/html/sites/default';" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$config['system.performance']['css']['preprocess'] = FALSE;" >> ${HOME}/runtime/drupal_settings.php
    /bin/echo "\$config['system.performance']['js']['preprocess'] = FALSE;" >> ${HOME}/runtime/drupal_settings.php 
fi

WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh "${WEBSITE_DISPLAY_NAME}" 

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
