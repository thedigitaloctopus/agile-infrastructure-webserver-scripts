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

#If we are not a virgin, exit
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] ) 
then
    exit
fi

SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

credentials="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh credentials/shit" && eval ${command}`"

while ( [ "${credentials}" = "" ] )
do
    credentials="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh credentials/shit" && eval ${command}`"
    /bin/sleep 10
done

#If we have placed any tokens in our code base for credential modification between deployments, this will update them
DB_N="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh credentials/shit 1" && eval ${command}`"
DB_P="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh credentials/shit 2" && eval ${command}`"
DB_U="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh credentials/shit 3" && eval ${command}`"
DB_PORT="`command="${SUDO} ${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'" && eval ${command}`" 
DB_HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
prefix="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPREFIX'`"


if ( [ "${DB_HOST}" = "" ] ) 
then 
    DB_HOST="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*" && eval ${command}`" 
fi

#Wait for the prefix to be intialised
prefix="`command="${SUDO} /bin/cat /var/www/html/dbp.dat" && eval ${command}`"
while ( [ "${prefix}" = "" ] )
do
    /bin/sleep 10
    prefix="`command="${SUDO} /bin/cat /var/www/html/dbp.dat" && eval ${command}`"
done

