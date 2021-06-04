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

if ( [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

if ( [ -f ${HOME}/.ssh/BUILDARCHIVECHOICE:virgin ] )
then
    exit
fi

if ( [ ! -f /var/www/html/moodle/config.php ] )
then
    /bin/rm ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi

#If we the default configuration file hasn't been set yet, then exit. It will be on the shared config directory or the
#not shared runtime directory on an application by application basis
if ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ] && [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

websiteurl="`/bin/ls ${HOME}/.ssh/WEBSITEURL:* | /usr/bin/awk -F':' '{print $NF}'`"
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

if ( [ ! -d /var/www/html/moodledata ] )
then
    /bin/mkdir -p /var/www/html/moodledata/filedir
    /bin/chmod -R 750 /var/www/html/moodledata
    /bin/chown -R www-data.www-data /var/www/html/moodledata
fi

if ( [ -f /var/www/html/moodle/config.php ] &&
    [ -f ${HOME}/runtime/APPLICATION_DB_CONFIGURED ] &&
    [ "${name}" != "" ] && [ "${database}" != "" ] && [ "${password}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${name}"`" != "" ]  &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${database}"`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${password}"`" != "" ]  &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${host}"`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "dbport" | /bin/grep "${DB_PORT}"`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "dataroot" | /bin/grep "\/var\/www\/html\/moodledata"`" != "" ] &&
[ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "wwwroot" | /bin/grep "${websiteurl}"`" != "" ]  )
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
/bin/sed -i '/\/\/.*\\core\\session\\database/s/^\/\///' /var/www/html/moodle/config.php
/bin/sed -i '/\/\/.*session_database_acquire_lock_timeout/s/^\/\///' /var/www/html/moodle/config.php

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] ||  [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    if ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" /var/www/html/moodle/config.php
    elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" /var/www/html/moodle/config.php
    elif ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Postgres ] )
    then
        /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" /var/www/html/moodle/config.php
    fi
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" /var/www/html/moodle/config.php
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" /var/www/html/moodle/config.php    
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] )
then
    /bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" /var/www/html/moodle/config.php
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${name}"`" = "" ] )
then
    /bin/sed -i "/->dbuser /c\    \$CFG->dbuser    = \"${name}\";" /var/www/html/moodle/config.php
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${database}"`" = "" ] )
then
    /bin/sed -i "/->dbname /c\    \$CFG->dbname    = \"${database}\";" /var/www/html/moodle/config.php
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${password}"`" = "" ] )
then
    /bin/sed -i "/->dbpass /c\    \$CFG->dbpass    = \"${password}\";" /var/www/html/moodle/config.php
fi

if ( [ "${host}" = "127.0.0.1" ] || ( [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${host}"`" = "" ]  && [ "${host}" != "" ] ) )
then
    /bin/sed -i "/->dbhost /c\    \$CFG->dbhost    = \"${host}\";" /var/www/html/moodle/config.php
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "dbport" | /bin/grep "${DB_PORT}"`" = "" ] )
then
    /bin/sed -i "/dbport/c\     \'dbport\' => \'${DB_PORT}\'," /var/www/html/moodle/config.php
fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "wwwroot" | /bin/grep "${websiteurl}"`" = "" ] )
then
    # /bin/sed -i "/\$CFG->wwwroot/c\     \$CFG->wwwroot    = \"https://${websiteurl}/moodle\";" /var/www/html/moodle/config.php
    /bin/sed -i "0,/\$CFG->wwwroot/ s/\$CFG->wwwroot.*/\$CFG->wwwroot = \"https:\/\/${websiteurl}\/moodle\";/" /var/www/html/moodle/config.php

fi

if ( [ -f /var/www/html/moodle/config.php ] && [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "moodledata" | /bin/grep "dataroot" | /bin/grep "\/var\/www\/html\/moodledata"`" = "" ] )
then
    /bin/sed -i "0,/\$CFG->dataroot/ s/\$CFG->dataroot.*/\$CFG->dataroot = \'\/var\/www\/html\/moodledata\';/" /var/www/html/moodle/config.php
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


if ( [ "${name}" != "" ] && [ "${database}" != "" ] && [ "${password}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${name}"`" != "" ]  &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${database}"`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${password}"`" != "" ]  &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "${host}"`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "dbport" | /bin/grep "${DB_PORT}"`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "dataroot" | /bin/grep "\/var\/www\/html\/moodledata"`" != "" ] &&
[ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep "wwwroot" | /bin/grep "${websiteurl}"`" != "" ]  )
then
    /bin/touch ${HOME}/runtime/APPLICATION_DB_CONFIGURED
fi

#As each machine has its own local configuration in moodle's case, we don't need to do any more than what we have done already
