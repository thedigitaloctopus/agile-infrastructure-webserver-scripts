#!/bin/sh
######################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This is an application specific script which processes geolocation information for the
# users of a social neworking application
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

/bin/echo "${0} `/bin/date`: Writing geolocation to S3" >> ${HOME}/logs/MonitoringLog.dat

if ( [ -f /tmp/geolocation.dat ] )
then
    /bin/sed -i '/::/d' /tmp/geolocation.dat
    /bin/cp /tmp/geolocation.dat ${HOME}/config/geolocation/geolocation.dat
    /bin/rm /tmp/geolocation.dat
fi
