#!/bin/sh
#########################################################################################
# Description: This script will initialise a virgin copy of an application on the server.
# It should be fully primed for use once this script is run, with username, password and
# database set up automatically.
# Date: 16/11/2016
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
####################################################################################
####################################################################################
#set -x

#if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
#then
#    exit
#fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
   exit
fi

#If the shared credentials are not available, simply exit this time around
#if ( [ ! -f ${HOME}/config/credentials/shit ] )
#then
#    exit
#fi

#If our credentials are not available, that's no good to us
DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"

if ( [ "${DB_N}" = "" ] )
then
    exit
fi

for applicationdir in `/bin/ls -d ${HOME}/providerscripts/application/configuration/*/`
do
    applicationname="`/bin/echo ${applicationdir} | /bin/sed 's/\/$//' | /usr/bin/awk -F'/' '{print $NF}' | /usr/bin/tr 'a-z' 'A-Z'`"
    if ( [ "`/bin/grep -a "APPLICATIONBASELINESOURCECODEREPOSITORY:${applicationname}" ${HOME}/.ssh/webserver_configuration_settings.dat`" != "" ] )
    then
        . ${applicationdir}InitialiseVirginInstall.sh
    fi
done
