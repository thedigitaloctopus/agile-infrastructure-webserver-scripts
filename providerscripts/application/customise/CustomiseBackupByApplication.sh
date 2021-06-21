#!/bin/sh
####################################################################################
# Description: Sometimes when we are making a backup of our application, there are
# some additional steps required. We can put them here by creating a sub directory
# for our application and updating it accordingly
# Author: Peter Winter
# Date: 05/01/2017
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
####################################################################################
####################################################################################
#set -x

for applicationdir in `/bin/ls -d ${HOME}/providerscripts/application/customise/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}'`"
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:${applicationname}`" = "1" ] )
    then
        . ${applicationdir}CustomiseBackup.sh
    fi
done

#We can strip out our DB credentials and replace them with placeholders which we can again replace
#the next time we deploy our application. That way, we have current DB credentials in our codebase
#each time we do a fresh deploy and not the credentials from the previous deployment which would be no good.

if ( [ ! -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:None ] )
then
    DB_N="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"
    DB_P="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
    DB_U="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"
    DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DB_PORT'`"

    DB_HOST="`/bin/ls ${HOME}/config/databaseip`"

    if ( [ "`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSREMOTESSHPROXYIP'`" != "" ] )
    then
        DB_HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSREMOTESSHPROXYIP'`"
    fi

    if ( [ "`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`" != "" ] )
    then
        DB_HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
    fi

fi

if ( [ "${1}" != "" ] )
then
    /usr/bin/find ${HOME}/backups/${baseline_name} -type f -exec sed -i -e "s/${DB_U}/XXXUSERNAMEXXX/g" -e "s/${DB_P}/XXXPASSWORDXXX/g" -e "s/${DB_N}/XXXDATABASEXXX/g" -e "s/${DB_PORT}/XXXDBPORTXXX/g" -e "s/${DB_HOST}/XXXDBHOSTXXX/g" {} \;
else
    /usr/bin/find /tmp/backup -type f -exec sed -i -e "s/${DB_U}/XXXUSERNAMEXXX/g" -e "s/${DB_P}/XXXPASSWORDXXX/g" -e "s/${DB_N}/XXXDATABASEXXX/g" -e "s/${DB_PORT}/XXXDBPORTXXX/g" -e "s/${DB_HOST}/XXXDBHOSTXXX/g" {} \;
fi
