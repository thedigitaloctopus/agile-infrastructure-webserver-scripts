
#!/bin/sh
######################################################################################################
# Description: This script will install the lighttpd webserver
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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

if ( [ "${1}" != "" ] )
then
    BUILDOS="${1}"
fi

if ( [ "${BUILDOS}" = "ubuntu" ] )
then

    
    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] )
    then
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        ${HOME}/installscripts/lighttpd/BuildLighttpdFromSource.sh 
        /bin/touch /etc/apache2/BUILT_FROM_SOURCE
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'LIGHTTPD:repo'`" = "1" ] )
    then
        /usr/bin/systemctl disable --now apache2
        /usr/bin/apt-get -y -qq install lighttpd
        /bin/touch /etc/apache2/BUILT_FROM_REPO
    fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'LIGHTTPD:source'`" = "1" ] )
    then
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        ${HOME}/installscripts/lighttpd/BuildLighttpdFromSource.sh 
        /bin/touch /etc/apache2/BUILT_FROM_SOURCE
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'LIGHTTPD:repo'`" = "1" ] )
    then
        /usr/bin/apt-get -y -qq install lighttpd
        /bin/touch /etc/apache2/BUILT_FROM_REPO
    fi
fi

