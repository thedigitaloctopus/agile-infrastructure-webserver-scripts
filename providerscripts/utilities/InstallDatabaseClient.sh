#!/bin/sh
###################################################################################
# Description: This script installs the CLI database client for our database. This
# enables scripts to connect to the database from the command line as they need to.
# Author: Peter Winter
# Date: 08/01/2017
###################################################################################
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
###################################################################################
###################################################################################
#set -x

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] )
then
    ${HOME}/installscripts/InstallMariaDBClient.sh ${BUILDOS}
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] ||  [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Postgres ] )
then
    ${HOME}/installscripts/InstallPostgresClient.sh ${BUILDOS}
fi
if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:MySQL ] )
then
    ${HOME}/installscripts/InstallMySQLClient.sh ${BUILDOS}
fi
