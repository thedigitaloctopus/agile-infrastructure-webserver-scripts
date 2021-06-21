#!/bin/sh
########################################################################################
# Description: This script will verify and set a flag to indicate that the application configuration
# has been set up fully and correctly
# Author: Peter Winter
# Date: 04/01/2017
########################################################################################
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

if ( [ "`/usr/bin/curl -I --insecure https://localhost/moodle/index.php | /bin/grep HTTP | /bin/grep 200`" = "" ] &&
[ "`/usr/bin/curl -I --insecure https://localhost/moodle/index.php | /bin/grep HTTP | /bin/grep 303`" = "" ] )
then
    /bin/rm ${HOME}/runtime/CONFIG_VERIFIED
fi

if ( [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    exit
fi

#Sleep first so as not to initiate a race condition with the other configuration scripts
/bin/sleep 40

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
    host="`/bin/ls ${HOME}/config/databaseip | /usr/bin/head -1`"
fi

username="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"
password="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
database="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"


if ( [ -f /var/www/html/moodle/config.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat /var/www/html/moodle/config.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/runtime/CONFIG_VERIFIED
else
    /bin/rm ${HOME}/runtime/VIRGINCONFIGSET
    /bin/rm ${HOME}/runtime/CONFIG_VERIFIED
fi
