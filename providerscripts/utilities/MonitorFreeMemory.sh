#!/bin/sh
###################################################################################
# Description: This script will send out a low memory email when the memory
# remaining on the machine is less than 100MB
# Author: Peter Winter
# Date: 23/02/2017
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
#######################################################################################
#######################################################################################

if ( [ "`/bin/cat /proc/meminfo | /bin/grep MemFree`" -lt "100000" ] )
then
    ${HOME}/providerscripts/email/SendEmail.sh "LOW MEMORY WARNING" "You have less than 100 MB of memory remaining on machine `${HOME}/providerscripts/utilities/GetPublicIP.sh`"
fi
