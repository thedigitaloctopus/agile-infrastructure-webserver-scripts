#!/bin/sh
#################################################################################################################
# Author: Peter Winter
# Date  : 9/4/2016
# Description : This is an application specific script. It is used by a social networking application to
# process status updates from the activity feed within the application
###########################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

/bin/echo "${0} `/bin/date`: Processing status updates. Mesages are written to /tmp/messages.dat and then put in the datastore to be picked up by the DB and inserted into the Database" >> ${HOME}/logs/MonitoringLog.dat
/bin/sed -i 's/{.*}//g' /tmp/messages.dat
/bin/mv /tmp/messages.dat /tmp/messages.dat.`${HOME}/providerscripts/utilities/GetIP.sh`
/bin/cp /tmp/message.dat.`${HOME}/providerscripts/utilities/GetIP.sh` ${HOME}/config/statusupdates
/bin/rm /tmp/messages.dat.`${HOME}/providerscripts/utilities/GetIP.sh`
