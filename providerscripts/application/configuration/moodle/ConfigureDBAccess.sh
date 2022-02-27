#!/bin/sh
##################################################################################
# Description: This script will update update the database credentials for moodle
# Author: Peter Winter
# Date: 05/01/2017
###################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

#Check that we have a prefix available, there must be an existing and well known prefix
dbprefix="`/bin/cat /var/www/html/dbp.dat`"
if ( [ "${dbprefix}" = "" ] )
then

    dbprefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh UPDATEDPREFIX:*`"
fi
if ( [ "${dbprefix}" = "" ] )
then
    exit
fi
if ( [ "`/bin/grep ${dbprefix} ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->prefix /c\    \$CFG->prefix    = \"${dbprefix}_\";" ${HOME}/runtime/moodle_config.php
    /bin/touch ${HOME}/runtime/moodle_config.php
    /bin/echo "${0} `/bin/date`: Updating the database prefix" >> ${HOME}/logs/MonitoringLog.dat
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh UPDATEDPREFIX:*`" != "" ] )
    then
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "UPDATEDPREFIX:*"
    fi
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh UPDATEDPREFIX:${dbprefix}    
fi

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
then
    exit
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/moodle-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
fi

websiteurl="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/moodle-htaccess.txt /var/www/html/.htaccess
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
else
    host="${dbip}"
fi

if ( [ ! -d /var/www/html/moodledata ] )
then
    /bin/mkdir -p /var/www/html/moodledata/filedir
    /bin/chmod -R 755 /var/www/html/moodledata
    /bin/chown -R www-data.www-data /var/www/html/moodledata
fi

if ( [ -f /var/www/html/moodle/config.php ] &&
    [ "${name}" != "" ] && [ "${database}" != "" ] && [ "${password}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep "${name}" /var/www/html/moodle/config.php`" != "" ]  &&
    [ "`/bin/grep "${database}" /var/www/html/moodle/config.php`" != "" ] &&
    [ "`/bin/grep "${password}" /var/www/html/moodle/config.php `" != "" ]  &&
    [ "`/bin/grep "${host}" /var/www/html/moodle/config.php`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "dbport" | /bin/grep "${DB_PORT}"`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "dataroot" | /bin/grep "\/var\/www\/html\/moodledata"`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "wwwroot" | /bin/grep "${websiteurl}"`" != "" ]  )
then
    if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
    then
        /bin/echo " " >> ${HOME}/runtime/moodle_config.php 
    fi
    /bin/touch ${HOME}/runtime/APPLICATION_DB_CONFIGURED
    exit
else
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi

if ( [ -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] && [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ] )
then
    exit
fi

#Remember if we are here, we are installing from a backup or a baseline. For moodle, backups and baselines are
#customised to have the moodledata in the webroot. We don't want it there, however, so move it to where we do
#want it
/bin/chown -R www-data.www-data /var/www/html/moodledata

cd ${HOME}

#This is needed when the autoscaler checks for the webserver being up. Moodle is a bit odd, so we have to put this in
/bin/echo "<?php
echo \"hello, you need to surf to ${WEBSITEURL}/moodle \"
?>" > /var/www/html/index.php

#Set session handler to be database. May (will) get issues if trying to use filesystem
/bin/sed -i '/\/\/.*\\core\\session\\database/s/^\/\///' ${HOME}/runtime/moodle_config.php 
/bin/sed -i '/\/\/.*session_database_acquire_lock_timeout/s/^\/\///' ${HOME}/runtime/moodle_config.php 

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${HOME}/runtime/moodle_config.php 
        /bin/echo "For your information, this website uses Maria DB" > /var/www/html/dbe.dat
    elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" ${HOME}/runtime/moodle_config.php 
        /bin/echo "For your information, this website uses MySQL" > /var/www/html/dbe.dat
    elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" ${HOME}/runtime/moodle_config.php 
        /bin/echo "For your information, this website uses Postgres" > /var/www/html/dbe.dat
    fi
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "For your information, this website uses MariaDB" > /var/www/html/dbe.dat
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "For your information, this website uses MySQL" > /var/www/html/dbe.dat
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" ${HOME}/runtime/moodle_config.php 
    /bin/echo "For your information, this website uses Postgres" > /var/www/html/dbe.dat
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/grep "${name}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbuser /c\    \$CFG->dbuser    = \"${name}\";" ${HOME}/runtime/moodle_config.php 
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/grep "${database}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbname /c\    \$CFG->dbname    = \"${database}\";" ${HOME}/runtime/moodle_config.php 
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/grep "${password}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbpass /c\    \$CFG->dbpass    = \"${password}\";" ${HOME}/runtime/moodle_config.php 
fi

if ( [ "${host}" = "127.0.0.1" ] || ( [ "`/bin/grep "${host}" ${HOME}/runtime/moodle_config.php`" = "" ]  && [ "${host}" != "" ] ) )
then
    /bin/sed -i "/->dbhost /c\    \$CFG->dbhost    = \"${host}\";" ${HOME}/runtime/moodle_config.php 
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/cat ${HOME}/runtime/moodle_config.php | /bin/grep "dbport" | /bin/grep "${DB_PORT}"`" = "" ] )
then
    /bin/sed -i "/dbport/c\     \'dbport\' => \'${DB_PORT}\'," ${HOME}/runtime/moodle_config.php 
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/cat ${HOME}/runtime/moodle_config.php | /bin/grep "wwwroot" | /bin/grep "${websiteurl}"`" = "" ] )
then
    # /bin/sed -i "/\$CFG->wwwroot/c\     \$CFG->wwwroot    = \"https://${websiteurl}/moodle\";" ${HOME}/runtime/moodle_config.php 
    /bin/sed -i "0,/\$CFG->wwwroot/ s/\$CFG->wwwroot.*/\$CFG->wwwroot = \"https:\/\/${websiteurl}\/moodle\";/" ${HOME}/runtime/moodle_config.php 

fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/cat ${HOME}/runtime/moodle_config.php | /bin/grep "moodledata" | /bin/grep "dataroot" | /bin/grep "\/var\/www\/html\/moodledata"`" = "" ] )
then
    /bin/sed -i "0,/\$CFG->dataroot/ s/\$CFG->dataroot.*/\$CFG->dataroot = \'\/var\/www\/html\/moodledata\';/" ${HOME}/runtime/moodle_config.php 
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

