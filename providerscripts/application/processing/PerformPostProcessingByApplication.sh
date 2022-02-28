#!/bin/sh
#######################################################################################
# Description: This script performs any application specific post processing as required
# Date: 18/11/2016
# Author: Peter Winter
######################################################################################
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
######################################################################################
######################################################################################
#set -x

SERVER_USER="${1}"

for applicationdir in `/bin/ls -d /home/${SERVER_USER}/providerscripts/application/processing/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
    if ( [ "`/home/${SERVER_USER}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
    then
        if ( [ "`/home/${SERVER_USER}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
       then
           . ${applicationdir}PerformPostProcessing.sh
       fi
    fi
done

if ( [ "`/home/${SERVER_USER}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:None`" = "0" ] )
then
 #   while ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
 #   do
 #       /bin/sleep 10
 #   done

    SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
    SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

   # credentials="`command="${SUDO} /bin/ls ${HOME}/config/credentials/shit" && eval ${command}`"

   # while ( [ "${credentials}" = "" ] )
   # do
   #     credentials="`command="${SUDO} /bin/ls ${HOME}/config/credentials/shit" && eval ${command}`"
   #     /bin/sleep 10
   # done
   
    credentials="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh credentials/shit" && eval ${command}`"
   
    while ( [ "${credentials}" = "" ] )
    do
        credentials="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh credentials/shit" && eval ${command}`"
        /bin/sleep 10
    done
    
    #If we have placed any tokens in our code base for credential modification between deployments, this will update them
   # DB_U="`command="${SUDO} /bin/sed '3q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
   # DB_P="`command="${SUDO} /bin/sed '2q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
   # DB_N="`command="${SUDO} /bin/sed '1q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
    DB_N="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh credentials/shit 1" && eval ${command}`"
    DB_P="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh credentials/shit 2" && eval ${command}`"
    DB_U="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh credentials/shit 3" && eval ${command}`"
    DB_PORT="`command="${SUDO} ${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'" && eval ${command}`"
    DB_HOST="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*" && eval ${command}`"
    

    if ( [ "`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`" != "" ] )
    then
        DB_HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
    fi

    directoriestomiss="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

    if ( [ "${directoriestomiss}" = "" ] )
    then
        command="${SUDO} /usr/bin/find /var/www/html -type f -exec sed -i -e \"s/XXXUSERNAMEXXX/${DB_U}/g\" -e \"s/XXXPASSWORDXXX/${DB_P}/g\" -e \"s/XXXDATABASEXXX/${DB_N}/g\" -e \"s/XXXDBPORTXXX/${DB_PORT}/g\" -e \"s/XXXDBHOSTXXX/${DB_HOST}/g\" {} \;" && eval ${command}
    else
        command="${SUDO} /usr/bin/find /var/www/html/ -type f -not -path "

        for directorytomiss in ${directoriestomiss}
        do
            command=${command}"'/var/www/html/${directorytomiss}/*' -not -path "
            command=${command}"'/var/www/html/${directorytomiss}' -not -path "
        done

        command="`/bin/echo ${command} | /bin/sed 's/-not -path$//g'`"
        command="${command} -exec sed -i -e \"s/XXXUSERNAMEXXX/${DB_U}/g\" -e \"s/XXXPASSWORDXXX/${DB_P}/g\" -e \"s/XXXDATABASEXXX/${DB_N}/g\" -e \"s/XXXDBPORTXXX/${DB_PORT}/g\" -e \"s/XXXDBHOSTXXX/${DB_HOST}/g\" {} \;" && eval ${command}
    fi
fi
