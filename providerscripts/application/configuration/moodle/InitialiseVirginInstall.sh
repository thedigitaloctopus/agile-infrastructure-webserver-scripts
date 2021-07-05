#!/bin/sh
#####################################################################################
# Description: This script will initialise a virgin copy of moodle
# Author: Peter Winter
# Date: 04/01/2017
#######################################################################################
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
#######################################################################################
#######################################################################################
#set -x

if ( [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] )
then
    exit
fi

if ( [ ! -f /var/www/html/moodle/config.php ] )
then
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
fi

if ( [ -f ${HOME}/runtime/VIRGINCONFIGSET ] )
then
    exit
fi

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] || [ ! -f ${HOME}/config/credentials/shit ] )
then
    exit
fi

if ( [ -f /var/www/html/moodle/config-dist.php ] )
then
    /bin/mv /var/www/html/moodle/config-dist.php /var/www/html/moodle/config.php.default
fi

if ( [ -f /var/www/html/moodle/config.php.default ] )
then
    /bin/cp /var/www/html/moodle/config.php.default /var/www/html/moodle/config.php
fi

if ( [ ! -f /var/www/html/.htaccess ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/moodle-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    /bin/chmod 440 /var/www/html/.htaccess
fi

if ( [ ! -d /var/www/html/moodledata ] )
then
    /bin/mkdir -p /var/www/html/moodledata/filedir
    /bin/chmod -R 750 /var/www/html/moodledata
    /bin/chown -R www-data.www-data /var/www/html/moodledata
fi

name="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"
database="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"
password="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
websiteurl="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DB_PORT'`"

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

cd ${HOME}

#This is needed when the autoscaler checks for the webserver being up. Moodle is a bit odd, so we have to put this in
/bin/echo "<?php
echo \"hello, you need to surf to ${websiteurl}/moodle \"
?>" > /var/www/html/index.php



#Set session handler to be database. May (will) get issues if trying to use filesystem
/bin/sed -i '/\/\/.*\\core\\session\\database/s/^\/\///' /var/www/html/moodle/config.php
/bin/sed -i '/\/\/.*session_database_acquire_lock_timeout/s/^\/\///' /var/www/html/moodle/config.php

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" /var/www/html/moodle/config.php
    elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" /var/www/html/moodle/config.php
    elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" /var/www/html/moodle/config.php
    fi
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" /var/www/html/moodle/config.php
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" /var/www/html/moodle/config.php
elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" /var/www/html/moodle/config.php
fi

if ( [ "`/bin/grep "${name}" /var/www/html/moodle/config.php`" = "" ] )
then
    /bin/sed -i "/->dbuser /c\    \$CFG->dbuser    = \"${name}\";" /var/www/html/moodle/config.php
fi
if ( [ "`/bin/grep "${database}" /var/www/html/moodle/config.php`" = "" ] )
then
    /bin/sed -i "/->dbname /c\    \$CFG->dbname    = \"${database}\";" /var/www/html/moodle/config.php
fi
if ( [ "`/bin/grep "${password}" /var/www/html/moodle/config.php`" = "" ] )
then
    /bin/sed -i "/->dbpass /c\    \$CFG->dbpass    = \"${password}\";" /var/www/html/moodle/config.php
fi
if ( [ "${host}" = "127.0.0.1" ] || ( [ "`/bin/grep "${host}" /var/www/html/moodle/config.php`" = "" ]  && [ "${host}" != "" ] ) )
then
    /bin/sed -i "/->dbhost /c\    \$CFG->dbhost    = \"${host}\";" /var/www/html/moodle/config.php
fi
if ( [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "dbport" | /bin/grep "${DB_PORT}"`" = "" ] )
then
    /bin/sed -i "/dbport/c\     \'dbport\' => \"${DB_PORT}\"," /var/www/html/moodle/config.php
fi

websiteurl="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

if ( [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "wwwroot" | /bin/grep "${websiteurl}"`" = "" ] )
then
    /bin/sed -i "/\$CFG->wwwroot/c\     \$CFG->wwwroot    = \"https://${websiteurl}/moodle\";" /var/www/html/moodle/config.php
fi

if ( [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "moodledata" | /bin/grep "dataroot" | /bin/grep "\/var\/www\/html\/moodledata"`" = "" ] )
then
    /bin/sed -i "/\$CFG->dataroot/c\    \$CFG->dataroot    = '/var/www/html/moodledata';" /var/www/html/moodle/config.php
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


if ( [ "${name}" != "" ] && [ "${database}" != "" ] && [ "${password}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep "${name}" /var/www/html/moodle/config.php`" != "" ] &&
    [ "`/bin/grep "${database}" /var/www/html/moodle/config.php`" != "" ] &&
    [ "`/bin/grep "${password}" /var/www/html/moodle/config.php`" != "" ] &&
    [ "`/bin/grep "${host}" /var/www/html/moodle/config.php`" != "" ]  &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "dbport" | /bin/grep "${DB_PORT}"`" != "" ] &&
[ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "wwwroot" | /bin/grep "${websiteurl}"`" != "" ] )
then
    /bin/touch ${HOME}/runtime/VIRGINCONFIGSET
fi

