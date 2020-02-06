#!/bin/sh
#################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Runs a check to see if the database is up and running
#################################################################################
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
#####################################################################################
#####################################################################################
#set -x

SERVER_USER="`/bin/ls ${HOME}/.ssh/SERVERUSER:* | /usr/bin/awk -F':' '{print $NF}'`"
SSH_PORT="`/bin/ls ${HOME}/.ssh/SSH_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

/bin/echo "${0} `/bin/date`: Checking if the database is up" >> ${HOME}/logs/MonitoringLog.dat
dbip="`/bin/ls ${HOME}/config/databaseip`"
/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${SERVER_USER}@${dbip} -p ${SSH_PORT} '${HOME}/providerscripts/utilities/IsDatabaseUp.sh'

