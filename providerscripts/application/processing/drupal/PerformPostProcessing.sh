#!/bin/sh
######################################################################################################################################
# Description: If your application requires any post processing to be performed, then, this is the place to put it. Post processing is considered to be 
# any processing which is required after the application is considered installed. This is the post processing for a drupal install. If you examine the 
# code, you will find that this script is called from the build client over ssh once it considers that the application has been fully installed. Author: 
# Peter Winter Date: 04/01/2017
######################################################################################################################################################
# License Agreement: This file is part of The Agile Deployment Toolkit. The Agile Deployment Toolkit is free software: you can redistribute it and/or 
# modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your 
# option) any later version. The Agile Deployment Toolkit is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have 
# received a copy of the GNU General Public License along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#######################################################################################################
#set -x

while ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] ) 
do 
        /bin/sleep 10 
done

SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

credentials="`command="${SUDO} /bin/ls ${HOME}/config/credentials/shit" && eval ${command}`"

while ( [ "${credentials}" = "" ] ) 
do 
        credentials="`command="${SUDO} /bin/ls ${HOME}/config/credentials/shit" && eval ${command}`" 
        /bin/sleep 10 
done

#If we have placed any tokens in our code base for credential modification between deployments, this will update them
DB_U="`command="${SUDO} /bin/sed '3q;d' ${HOME}/config/credentials/shit" && eval ${command}`" DB_P="`command="${SUDO} /bin/sed '2q;d' 
${HOME}/config/credentials/shit" && eval ${command}`" DB_N="`command="${SUDO} /bin/sed '1q;d' ${HOME}/config/credentials/shit" && eval ${command}`" 
#DB_PORT="`command="${SUDO} /bin/ls ${HOME}/.ssh/DB_PORT:*" && eval ${command}`" DB_PORT="`/bin/echo ${DB_PORT} | /usr/bin/awk -F':' '{print $NF}'`"
DB_PORT="`command="${SUDO} ${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'" && eval ${command}`" 
DB_HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"


if ( [ "${DB_HOST}" = "" ] ) 
then 
    DB_HOST="`command="${SUDO} /bin/ls ${HOME}/config/databaseip" && eval ${command}`" 
fi
#prefix="`/bin/cat /var/www/html/dpb.dat`"



#if ( [ "${prefix}" = "" ] && [ ! -f /var/www/html/dpb.dat ] )
if ( [ ! -f /var/www/html/dpb.dat ] )
then
    prefix="`< /dev/urandom tr -dc a-z | head -c${1:-6};echo;`"
    ${HOME}/providerscripts/utilities/StoreConfigValue.sh "DBPREFIX" "${prefix}"
  #  /bin/touch ${HOME}/.ssh/DBPREFIX:${prefix}
  #  /bin/chown www-data.www-data ${HOME}/.ssh/DBPREFIX:*
  #  /bin/chmod 755 ${HOME}/.ssh/DBPREFIX:*
    /bin/echo "${prefix}" > /var/www/html/dpb.dat
else
    prefix="`command="${SUDO} /bin/cat /var/www/html/dpb.dat" && eval ${command}`"
fi

#if ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Postgres ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] )
#then
#    export PGPASSWORD="${DB_P}"
 #   /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_bootstrap"
 #   /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_config"
 #   /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_container" 
 #   /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_data"
  #  /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_default"
 #   /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_discovery" 
 #   /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_dynamic_page_cache"
 #   /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_entity"
  #  /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_menu"
  #  /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_page" 
 #   /usr/bin/psql -U ${DB_U} -h ${DB_HOST} -p ${DB_PORT} ${DB_N} -c "truncate ${prefix}_cache_render"
#fi

#if ( ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] ) ||
  #   ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] ) )
#then
 #   /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_bootstrap"
 #   /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_config"
 #   /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_container" 
 #   /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_data"
 #   /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_default"
  #  /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_discovery" 
  #  /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_dynamic_page_cache"
 #   /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_entity"
 #   /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_menu"
  #  /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_page" 
 #   /usr/bin/mysql -u ${DB_U} -p${DB_P} --port ${DB_PORT} --host=${DB_HOST} ${DB_N} -e "DELETE from ${prefix}_cache_render"
#fi
