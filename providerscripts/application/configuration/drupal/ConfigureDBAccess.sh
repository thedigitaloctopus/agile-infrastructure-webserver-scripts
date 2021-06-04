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

for directory in ${directories}
do
   mounted_directories="`/bin/ls ${HOME}/.ssh/DIRECTORIESTOMOUNT:*`"
   if ( [ "`/bin/echo ${mounted_directories} | /bin/grep ${directory}`" = "" ] )
   then
       /bin/touch ${HOME}/.ssh/DIRECTORIESTOMOUNT:sites.default.files.${directory}
   fi
done

WEBSITE_URL="`/bin/ls ${HOME}/.ssh/WEBSITEURL:* | /usr/bin/awk -F':' '{print $NF}'`"
assetbucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' ' ' | /bin/sed 's/ //g'`"

for bucketstomount in `/usr/bin/s3cmd ls | /bin/grep "s3://${assetbucket}-sites-default-files"`
do
	bucketstomountextracted="`/bin/echo ${bucketstomount} | /bin/grep ^s3: | /bin/grep -v files$`"
        for buckettomount in ${bucketstomountextracted}
        do
            if ( [ "${buckettomount}" != "" ] )
	    then
                directory="`/bin/echo ${buckettomount} | /bin/sed 's/.*sites-default-files-//g' | /bin/grep -v s3:`"
                /bin/touch ${HOME}/.ssh/DIRECTORIESTOMOUNT:sites.default.files.${directory}
                directory="`/bin/echo ${buckettomount} | /bin/sed 's/.*sites-default-files-/sites\/default\/files\//g'`"
                /bin/mkdir -p /var/www/html/${directory}
	    fi
        done
done

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

if ( [ -f /var/www/html/sites/default/settings.php ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/html/sites/default/settings.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat /var/www/html/sites/default/settings.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat /var/www/html/sites/default/settings.php | /bin/grep ${database}`" != "" ] &&
    [ "`/bin/cat /var/www/html/sites/default/settings.php | /bin/grep ${host}`" != "" ] )
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
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${host}`" != "" ] )
then
    :
else
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ ! -f ${HOME}/runtime/drupal_settings.php ]  )
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

DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    database="`/bin/ls ${HOME}/.ssh/DBaaSDBNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
    password="`/bin/ls ${HOME}/.ssh/DBaaSPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
    name="`/bin/ls ${HOME}/.ssh/DBaaSUSERNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
fi

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

if ( [ ! -f ${HOME}/config/drupal_settings.php ] )
then
    /bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/config/drupal_settings.php ] &&
    [ -f ${HOME}/config/APPLICATION_DB_CONFIGURED ] &&
    [ "${name}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${host}`" != "" ] )
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

#Record which configuration file we are working on for use elsewhere
/bin/touch ${HOME}/.ssh/CONFIGFILE:drupal_settings.php

if ( [ -f ${HOME}/runtime/drupal_settings.php ] && [ "`/bin/cat ${HOME}/runtime/drupal_settings.php | /bin/grep "'${name}'"`" = "" ] || [ "`/bin/cat ${HOME}/runtime/drupal_settings.php | /bin/grep "'${password}'"`" = "" ] || [ "`/bin/cat ${HOME}/runtime/drupal_settings.php | /bin/grep "'${database}'"`" = "" ] || [ "`/bin/cat ${HOME}/runtime/drupal_settings.php | /bin/grep "'${name}'"`" = "" ] )
then
    prefix="`/bin/cat /var/www/html/dpb.dat`"

    # if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Postgres ] )
    # then
    #     /bin/sed -i "/^\$databases.*;/c  \$databases['default']['default'] = array ( \\n 'database' => '${database}', \\n 'username' => '${name}', \\n 'password' => '${password}', \\n 'host' => '${host}', \\n 'port' => '${DB_PORT}', \\n 'driver' => 'pgsql', \\n 'prefix' => '${prefix}_', \\n 'collation' => 'utf8mb4_general_ci', \\n );" ${HOME}/runtime/drupal_settings.php
    # else
    #     /bin/sed -i "/^\$databases.*;/c  \$databases['default']['default'] = array ( \\n 'database' => '${database}', \\n 'username' => '${name}', \\n 'password' => '${password}', \\n 'host' => '${host}', \\n 'port' => '${DB_PORT}', \\n 'driver' => 'mysql', \\n 'prefix' => '${prefix}_', \\n 'collation' => 'utf8mb4_general_ci', \\n );" ${HOME}/runtime/drupal_settings.php
    # fi

    /usr/bin/perl -i -pe 'BEGIN{undef $/;} s/^\$databases.\;/\$databases = [];/smg' ${HOME}/runtime/drupal_settings.php

    if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Postgres ] )
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
fi

WEBSITE_DISPLAY_NAME="`/bin/ls ${HOME}/.ssh/WEBSITEDISPLAYNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh \"${WEBSITE_DISPLAY_NAME}\"" 

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
    ( [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${name}`" = "" ] ||
        [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${password}`" = "" ] ||
        [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${database}`" = "" ] ||
[ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${host}`" = "" ] ) )
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
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${name}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep ${host}`" != "" ] )
then
    /bin/mkdir -p /var/www/html/sites/default/files/pictures
    /bin/chown -R www-data.www-data /var/www/html/sites/default
    /bin/touch ${HOME}/config/APPLICATION_DB_CONFIGURED
else
    /bin/cp ${HOME}/runtime/drupal_settings.php ${HOME}/config/drupal_settings.php
fi

