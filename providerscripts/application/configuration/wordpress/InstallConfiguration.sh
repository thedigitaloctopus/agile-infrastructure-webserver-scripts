#!/bin/sh
################################################################################
# Description: This script will install a wordpress configuration. There creates
# a default configuration to bundled with the  sourcecode which is used and customised
# for the particular deployment each time.
# Author: Peter Winter
# Date: 04/01/2017
###############################################################################
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
##################################################################################
##################################################################################
#set -x

while ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] || [ ! -f ${HOME}/config/credentials/shit ] )
do
    /bin/sleep 10
done


if ( [ -f ${HOME}/config/credentials/shit ] && [ ! -f ${HOME}/config/APPLICATION_CONFIGURATION_PREPARED ] )
then
    /bin/chmod 600 ${HOME}/config/wordpress_config.php
    /bin/touch ${HOME}/config/APPLICATION_CONFIGURATION_PREPARED
    /bin/echo "1"
fi
