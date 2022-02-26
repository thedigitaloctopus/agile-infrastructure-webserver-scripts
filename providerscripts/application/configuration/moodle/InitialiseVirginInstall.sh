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

database="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
password="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
username="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

if ( [ "${username}" = "" ] || [ "${password}" = "" ] || [ "${database}" = "" ] || [ "${host}" = "" ] )
then
    exit
fi


if ( ( [ -f /var/www/html/moodle/config.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/grep ${username} /var/www/html/moodle/config.php`" != "" ] &&
    [ "`/bin/grep ${password} /var/www/html/moodle/config.php`" != "" ] &&
    [ "`/bin/grep ${database} /var/www/html/moodle/config.php`" != "" ] &&
    [ "`/bin/grep ${host} /var/www/html/moodle/config.php`" != "" ] ) )
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
    /bin/cp ${HOME}/providerscripts/application/configuration/moodle-htaccess.txt /var/www/html/.htaccess
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

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "1" ] )
then
    exit
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
    /bin/chmod -R 755 /var/www/html/moodledata
    /bin/chown -R www-data.www-data /var/www/html/moodledata
fi

#This is needed when the autoscaler checks for the webserver being up. Moodle is a bit odd, so we have to put this in
/bin/echo "<?php
echo \"hello, you need to surf to ${websiteurl}/moodle \"
?>" > /var/www/html/index.php



#Set session handler to be database. May (will) get issues if trying to use filesystem
/bin/sed -i '/\/\/.*\\core\\session\\database/s/^\/\///' ${HOME}/runtime/moodle_config.php
/bin/sed -i '/\/\/.*session_database_acquire_lock_timeout/s/^\/\///' ${HOME}/runtime/moodle_config.php

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${HOME}/runtime/moodle_config.php
        /bin/echo "For your information, this website uses MariaDB" > /var/www/html/dbe.dat
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

if ( [ "`/bin/grep "${username}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbuser /c\    \$CFG->dbuser    = \"${username}\";" ${HOME}/runtime/moodle_config.php
fi
if ( [ "`/bin/grep "${database}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbname /c\    \$CFG->dbname    = \"${database}\";" ${HOME}/runtime/moodle_config.php
fi
if ( [ "`/bin/grep "${password}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->dbpass /c\    \$CFG->dbpass    = \"${password}\";" ${HOME}/runtime/moodle_config.php
fi
if ( [ "${host}" = "127.0.0.1" ] || ( [ "`/bin/grep "${host}" ${HOME}/runtime/moodle_config.php`" = "" ]  && [ "${host}" != "" ] ) )
then
    /bin/sed -i "/->dbhost /c\    \$CFG->dbhost    = \"${host}\";" ${HOME}/runtime/moodle_config.php
fi
if ( [ "`/bin/grep "${prefix}" ${HOME}/runtime/moodle_config.php`" = "" ] )
then
    /bin/sed -i "/->prefix /c\    \$CFG->prefix    = \"${prefix}_\";" ${HOME}/runtime/moodle_config.php
fi
if ( [ "`/bin/cat ${HOME}/runtime/moodle_config.php | /bin/grep "dbport" | /bin/grep "${DB_PORT}"`" = "" ] )
then
    /bin/sed -i "/dbport/c\     \'dbport\' => \"${DB_PORT}\"," ${HOME}/runtime/moodle_config.php
fi

websiteurl="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

if ( [ "`/bin/cat ${HOME}/runtime/moodle_config.php | /bin/grep "wwwroot" | /bin/grep "${websiteurl}"`" = "" ] )
then
    /bin/sed -i "/\$CFG->wwwroot/c\     \$CFG->wwwroot    = \"https://${websiteurl}/moodle\";" ${HOME}/runtime/moodle_config.php
fi

if ( [ "`/bin/cat ${HOME}/runtime/moodle_config.php | /bin/grep "moodledata" | /bin/grep "dataroot" | /bin/grep "\/var\/www\/html\/moodledata"`" = "" ] )
then
    /bin/sed -i "/\$CFG->dataroot/c\    \$CFG->dataroot    = '/var/www/html/moodledata';" ${HOME}/runtime/moodle_config.php
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
