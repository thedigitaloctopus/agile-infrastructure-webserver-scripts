#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/06/2021
# Description: Connect to the remote Postgres database and execute a query if 
# present. It uses the provided credentials that are part of the build process.
# It takes two parameters, the first is any command to execute and the second is whether
# it is to be of raw format or not. 
#####################################################################################
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

SERVER_USER="`/bin/ls ${HOME}/.ssh/SERVERUSER:* | /usr/bin/awk -F':' '{print $NF}'`"
SERVER_USER_PASSWORD="`/bin/ls ${HOME}/.ssh/SERVERUSERPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

sql_command="$1"
raw="$2"

DB_N="`command="${SUDO} /bin/sed '1q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
DB_P="`command="${SUDO} /bin/sed '2q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
DB_U="`command="${SUDO} /bin/sed '3q;d' ${HOME}/config/credentials/shit" && eval ${command}`"

HOST="`/bin/ls ${HOME}/config/databaseip`"
PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

export PGPASSWORD=${DB_P}

if ( [ "${raw}" != "raw" ] )
then
    if ( [ "${sql_command}" != "" ]  )
    then
        /usr/bin/psql -t -U ${DB_U} -h ${HOST} -p ${PORT} ${DB_N} -c "${sql_command}"
    else
        /usr/bin/psql -U ${DB_U} -h ${HOST} -p ${PORT} ${DB_N}
    fi
else
    if ( [ "${sql_command}" != "" ]  )
    then
        /usr/bin/psql -t -U ${DB_U} -h ${HOST} -p ${PORT} ${DB_N} -c "${sql_command}"
    else
        /usr/bin/psql -U ${DB_U} -h ${HOST} -p ${PORT} ${DB_N} 
    fi
fi
