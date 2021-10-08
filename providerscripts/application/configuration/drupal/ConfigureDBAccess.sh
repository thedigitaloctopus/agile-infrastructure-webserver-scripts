#!/bin/sh
####################################################################################
# Description: This script will update update the database credentials for drupal
# Author: Peter Winter
# Date: 05/01/2017
####################################################################################
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

directories="`/bin/ls /var/www/html/sites/default/files | /bin/grep "^20"`"

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
assetbucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' ' ' | /bin/sed 's/ //g'`"

for bucketstomount in `/usr/bin/s3cmd ls | /bin/grep "s3://${assetbucket}-sites-default-files"`
do
	bucketstomountextracted="`/bin/echo ${bucketstomount} | /bin/grep ^s3: | /bin/grep -v files$`"
        for buckettomount in ${bucketstomountextracted}
        do
            if ( [ "${buckettomount}" != "" ] )
	    then
                directory="`/bin/echo ${buckettomount} | /bin/sed 's/.*sites-default-files-//g' | /bin/grep -v s3:`"
                #/bin/touch ${HOME}/.ssh/DIRECTORIESTOMOUNT:sites.default.files.${directory}
		${HOME}/providerscripts/utilities/StoreConfigValue.sh "DIRECTORIESTOMOUNT" "sites.default.files.${directory}" "append"
                directory="`/bin/echo ${buckettomount} | /bin/sed 's/.*sites-default-files-/sites\/default\/files\//g'`"
                /bin/mkdir -p /var/www/html/${directory}
	    fi
        done
done

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    host="${dbip}"
fi

if ( [ -f /var/www/html/sites/default/settings.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${name} /var/www/html/sites/default/settings.php`" != "" ] &&
    [ "`/bin/grep ${password} /var/www/html/sites/default/settings.php`" != "" ] &&
    [ "`/bin/grep ${database} /var/www/html/sites/default/settings.php`" != "" ] &&
    [ "`/bin/grep ${host} /var/www/html/sites/default/settings.php`" != "" ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

if ( [ ! -f ${HOME}/config/drupal_settings.php ]  )
then
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/config/drupal_settings.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${name} ${HOME}/config/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep ${password} ${HOME}/config/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep ${database} ${HOME}/config/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep ${host} ${HOME}/config/drupal_settings.php`" != "" ] )
then
    :
else
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ ! -f ${HOME}/runtime/drupal_settings.php ]  )
then
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
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

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"


if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    database="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    password="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    name="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    host="${dbip}"
fi

if ( [ ! -f ${HOME}/config/drupal_settings.php ] )
then
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/config/drupal_settings.php ] &&
    [ -f ${HOME}/config/APPLICATION_DB_CONFIGURED ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${name} ${HOME}/config/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep ${password} ${HOME}/config/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep ${database} ${HOME}/config/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep ${host} ${HOME}/config/drupal_settings.php`" != "" ] )
then
    /bin/touch ${HOME}/config/APPLICATION_DB_CONFIGURED
    if ( [ ! -f /var/www/html/sites/default/settings.php ] )
    then
        /bin/cp ${HOME}/config/drupal_settings.php  /var/www/html/sites/default/settings.php
        exit
    else
        exit
    fi
else
    if ( [ -f /var/www/html/sites/default/default.settings.php ] )
    then
        /bin/rm ${HOME}/runtime/drupal_settings.php
        /bin/cp /var/www/html/sites/default/default.settings.php ${HOME}/runtime/drupal_settings.php
    fi
fi

if ( [ -f ${HOME}/runtime/drupal_settings.php ] && [ "`/bin/grep "'${name}'" ${HOME}/runtime/drupal_settings.php`" = "" ] || [ "`/bin/grep "'${password}'" ${HOME}/runtime/drupal_settings.php`" = "" ] || [ "`/bin/grep "'${database}'" ${HOME}/runtime/drupal_settings.php`" = "" ] || [ "`/bin/grep "'${name}'" ${HOME}/runtime/drupal_settings.php`" = "" ] )
then
    prefix="`/bin/cat /var/www/html/dpb.dat`"

    /usr/bin/perl -i -pe 'BEGIN{undef $/;} s/^\$databases.\;/\$databases = [];/smg' ${HOME}/runtime/drupal_settings.php

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        # /bin/sed -i "/^\$databases.*;/c  \$databases['default']['default'] = array ( \\n 'database' => '${database}', \\n 'username' => '${username}', \\n 'password' => '${password}', \\n 'host' => '${host}', \\n 'port' => '${DB_PORT}', \\n 'driver' => 'pgsql', \\n 'prefix' => '${prefix}_', \\n 'collation' => 'utf8mb4_general_ci', \\n );" ${HOME}/runtime/drupal_settings.php
        credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${database}', \n 'username' => '${name}', \n 'password' => '${password}', \n 'host' => '${host}', \n 'port' => '${DB_PORT}', \n 'driver' => 'pgsql', \n 'prefix' => '${prefix}_', \n 'collation' => 'utf8mb4_general_ci',\n);"
    else
        # /bin/sed -i "/^\$databases.*;/c  \$databases['default']['default'] = array ( \\n 'database' => '${database}', \\n 'username' => '${username}', \\n 'password' => '${password}', \\n 'host' => '${host}', \\n 'port' => '${DB_PORT}', \\n 'driver' => 'mysql', \\n 'prefix' => '${prefix}_', \\n 'collation' => 'utf8mb4_general_ci', \\n );" ${HOME}/runtime/drupal_settings.php
        credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${database}', \n 'username' => '${name}', \n 'password' => '${password}', \n 'host' => '${host}', \n 'port' => '${DB_PORT}', \n 'driver' => 'mysql', \n 'prefix' => '${prefix}_', \n 'collation' => 'utf8mb4_general_ci',\n);"
    fi

    /bin/sed -i "s/^\$databases = \[\]\;/${credentialstring}/" ${HOME}/runtime/drupal_settings.php

    salt="`< /dev/urandom tr -dc a-z | head -c${1:-16};echo;`"
    /bin/sed -i "/^\$settings\['hash_salt'\]/c\$settings['hash_salt'] = '${salt}';" ${HOME}/runtime/drupal_settings.php
fi

if ( [ "`/bin/grep 'ADDED BY CONFIG PROCESS' ${HOME}/runtime/drupal_settings.php`" = "" ] )
then
    /bin/echo "#====ADDED BY CONFIG PROCESS=====" >> ${HOME}/runtime/drupal_settings.php
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

if ( [ -f ${HOME}/config/drupal_settings.php ] &&
    ( [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] ) &&
    ( [ "`/bin/grep ${name} ${HOME}/config/drupal_settings.php`" = "" ] ||
      [ "`/bin/grep ${password} ${HOME}/config/drupal_settings.php`" = "" ] ||
      [ "`/bin/grep ${database} ${HOME}/config/drupal_settings.php`" = "" ] ||
      [ "`/bin/grep ${host} ${HOME}/config/drupal_settings.php`" = "" ] ) )
then

    if ( [ -f /var/www/html/sites/default/settings.php ] &&
    [ "`/usr/bin/diff ${HOME}/config/drupal_settings.php  ${HOME}/runtime/drupal_settings.php`" != "" ] )
    then
        /bin/cp ${HOME}/runtime/drupal_settings.php  ${HOME}/config/drupal_settings.php
        /bin/cp ${HOME}/runtime/drupal_settings.php  /var/www/html/sites/default/settings.php
    fi

    count="0"
    while ( [ "${count}" -lt "5" ] && [ "`/usr/bin/diff ${HOME}/config/drupal_settings.php  /var/www/html/sites/default/settings.php`" != "" ] )
    do
        /bin/cp ${HOME}/runtime/drupal_settings.php  ${HOME}/config/drupal_settings.php
        count="`/usr/bin/expr ${count} + 1`"
        /bin/sleep 5
    done

    if ( [ "${count}" = "5" ] )
    then
        /bin/echo "${0} `/bin/date`: Failed to copy the configuration file successfully" >> ${HOME}/logs/MonitoringLog.dat
        exit
    fi

    /bin/chown www-data.www-data ${HOME}/config/drupal_settings.php
    /bin/chmod 640 ${HOME}/config/drupal_settings.php
fi

if ( [ -f ${HOME}/config/drupal_settings.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${name} ${HOME}/config/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep ${password} ${HOME}/config/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep ${database} ${HOME}/config/drupal_settings.php`" != "" ] &&
    [ "`/bin/grep ${host} ${HOME}/config/drupal_settings.php`" != "" ] )
then
    /bin/mkdir -p /var/www/html/sites/default/files/pictures
    /bin/chown -R www-data.www-data /var/www/html/sites/default
    /bin/touch ${HOME}/config/APPLICATION_DB_CONFIGURED
else
    /bin/cp /var/www/html/sites/default/settings.php.default ${HOME}/runtime/drupal_settings.php
    /bin/cp ${HOME}/runtime/drupal_settings.php ${HOME}/config/drupal_settings.php
fi

