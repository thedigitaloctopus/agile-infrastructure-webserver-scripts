#!/bin/sh

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
