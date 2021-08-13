#!/bin/sh
###################################################################################
# Description: This  will perform a software upgrade
# Date: 18/11/2016
# Author : Peter Winter
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
####################################################################################
####################################################################################
#set -x

if ( [ "${1}" != "" ] )
then
    BUILDOS="${1}"
fi

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
   # DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -qq -y dist-upgrade --allow-change-held-packages
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -qq dist-upgrade -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef -y --allow-downgrades --allow-remove-essential --allow-change-held-packages
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    #DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -qq -y dist-upgrade --allow-change-held-packages
    DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -qq dist-upgrade -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef -y --allow-downgrades --allow-remove-essential --allow-change-held-packages
fi
