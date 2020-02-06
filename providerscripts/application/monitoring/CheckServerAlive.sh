#!/bin/sh
#############################################################################
# Description: This script will check if a webserver is alive and responsive
# on an application basis. You can add your new application to the subdirs and
# have it integrate into the framework.
# Date: 16-11-2016
# Author: Peter Winter
############################################################################
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
############################################################################
############################################################################
set -x

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:None ] )
then
    /bin/echo "ALIVE"
    exit
fi

DB_N="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"
DB_P="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
DB_U="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"

if ( [ ! -f ${HOME}/config/APPLICATION_CONFIGURATION_PREPARED ] && [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    if ( [ ! -f  ${HOME}/runtime/SSHTUNNELCONFIGURED ] )
    then
        exit
    fi
    SERVER_NAME="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    SERVER_NAME="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    SERVER_NAME="`/bin/ls ${HOME}/config/databaseip | /usr/bin/head -1`"
fi

if ( [ -f ${HOME}/.ssh/APPLICATION:joomla ] )
then
    . ${HOME}/providerscripts/application/monitoring/joomla/CheckServerAlive.sh
elif ( [ -f ${HOME}/.ssh/APPLICATION:wordpress ] )
then
    . ${HOME}/providerscripts/application/monitoring/wordpress/CheckServerAlive.sh
elif ( [ -f ${HOME}/.ssh/APPLICATION:moodle ] )
then
    . ${HOME}/providerscripts/application/monitoring/moodle/CheckServerAlive.sh
elif ( [ -f ${HOME}/.ssh/APPLICATION:drupal ] )
then
    . ${HOME}/providerscripts/application/monitoring/drupal/CheckServerAlive.sh
fi

if ( [ ! -f ${HOME}/.ssh/BUILDARCHIVECHOICE:virgin ] )
then
    ${HOME}/providerscripts/utilities/CheckServerAlive.sh
else
    /bin/echo "ALIVE"
fi

