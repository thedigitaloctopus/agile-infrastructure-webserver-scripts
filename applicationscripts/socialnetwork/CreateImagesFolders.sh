#!/bin/sh
#####################################################################################################################
# Description : This script is application specific and is used by the 'socialnetwork' application. It will initialise
# a gallery area for the phoca gallery component whenever a new user is added to the site
# Date: 16-11-2016
# Author: Peter Winter
###########################################################################################################
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

if ( [ "`/bin/ls -l /var/www/html/images | /usr/bin/wc -l`" -lt "10" ] || [ "`/bin/mount | /bin/grep images`" = "" ] )
then
    exit
fi

DB_N="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"

DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    if ( [ ! -f  ${HOME}/runtime/SSHTUNNELCONFIGURED ] )
    then
        exit
    fi
    DBIP="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    DBIP="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    DBIP="`/bin/ls ${HOME}/config/databaseip | /usr/bin/head -1`"
fi


# Get list of usernames from the DB
/usr/bin/mysql -A --user="${DB_U}" --password="${DB_P}" --database="${DB_N}" --host="${DBIP}" --port="${DB_PORT}" --execute="select name from uq893_users;" | /bin/grep -v "name" > ${HOME}/runtime/current_userlist
for user in `/bin/cat ${HOME}/runtime/current_userlist`
do
    if ( [ ! -f /var/www/html/images/phocagallery/${user} ] )
    then
        /bin/mkdir -p /var/www/html/images/phocagallery/${user}
        /bin/chmod 755 /var/www/html/images/phocagallery/${user}
    fi
done

