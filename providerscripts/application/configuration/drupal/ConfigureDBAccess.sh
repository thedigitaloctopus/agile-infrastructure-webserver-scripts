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

#Check that we have a prefix available, there must be an existing and well known prefix
prefix="`/bin/cat /var/www/html/dbp.dat`"
if ( [ "${prefix}" = "" ] )
then
    prefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh UPDATEDPREFIX:*`"
fi
if ( [ "${prefix}" = "" ] )
then
    exit
fi
if ( [ "`/bin/grep ${prefix} ${HOME}/runtime/drupal_settings.php`" = "" ] )
then
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh UPDATEDPREFIX:*`" != "" ] )
    then
	${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "UPDATEDPREFIX:*"
    fi
    /bin/touch ${HOME}/config/UPDATEDPREFIX:${prefix}
fi

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
    if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
    then
        /bin/echo " " >> ${HOME}/runtime/drupal_settings.php
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
    /bin/cp ${HOME}/providerscripts/application/configuration/drupal-htaccess.txt /var/www/html/.htaccess
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

/usr/bin/perl -i -pe 'BEGIN{undef $/;} s/^\$databases.\;/\$databases = [];/smg' ${HOME}/runtime/drupal_settings.php

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${database}', \n 'username' => '${name}', \n 'password' => '${password}', \n 'host' => '${host}', \n 'port' => '${DB_PORT}', \n 'driver' => 'pgsql', \n 'prefix' => '${prefix}_', \n 'collation' => 'utf8mb4_general_ci',\n);"
    /bin/echo "For your information, this website uses Postgres" > /var/www/html/dbe.dat
else
    credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${database}', \n 'username' => '${name}', \n 'password' => '${password}', \n 'host' => '${host}', \n 'port' => '${DB_PORT}', \n 'driver' => 'mysql', \n 'prefix' => '${prefix}_', \n 'collation' => 'utf8mb4_general_ci',\n);"
    /bin/echo "For your information, this website uses MySQL or MariaDB" > /var/www/html/dbe.dat
fi

/bin/sed -i "s/^\$databases = \[\]\;/${credentialstring}/" ${HOME}/runtime/drupal_settings.php
    
salt="`/bin/cat /var/www/html/salt`"
    
if ( [ "${salt}" = "" ] )
then
    salt="`/bin/cat /dev/urandom | /usr/bin/tr -dc a-z | /usr/bin/head -c${1:-16};echo;`"
fi

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


