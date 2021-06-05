#!/bin/sh

SERVER_USER="`/bin/ls ${HOME}/.ssh/SERVERUSER:* | /usr/bin/awk -F':' '{print $NF}'`"
SERVER_USER_PASSWORD="`/bin/ls ${HOME}/.ssh/SERVERUSERPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

sql_command="$1"

DB_N="`command="${SUDO} /bin/sed '1q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
DB_P="`command="${SUDO} /bin/sed '2q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
DB_U="`command="${SUDO} /bin/sed '3q;d' ${HOME}/config/credentials/shit" && eval ${command}`"

HOST="`/bin/ls ${HOME}/config/databaseip`"
PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${sql_command}" != "" ] )
then
    /usr/bin/mysql -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${PORT}" -e "${sql_command}"
else
    /usr/bin/mysql -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${PORT}"
fi
