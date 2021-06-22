
#!/bin/sh
######################################################################################################
# Description: This script will install the apache webserver
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

phpversion="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHP_VERSION'`"

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
 #   ${HOME}/installscripts/Update.sh ${BUILDOS}
 #   ${HOME}/installscripts/apache/BuildApacheFromSource.sh 
    
    /usr/bin/apt-get -qq -y install apache2
    if ( [  "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
    then
        /usr/bin/apt-get -qq -y install libapache2-mod-php${phpversion}
    fi
    ####/usr/bin/apt-get -qq -y install libapache2-modsecurity
    ####/usr/bin/apt-get -qq -y install modsecurity-crs
    /usr/bin/apt -qq -y install libapache2-mod-fcgid

fi

if ( [ "${BUILDOS}" = "debian" ] )
then
  #  ${HOME}/installscripts/Update.sh ${BUILDOS}
  #  ${HOME}/installscripts/apache/BuildApacheFromSource.sh
    
    /usr/bin/apt-get -qq -y install apache2
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
    then
        /usr/bin/apt-get -qq -y install libapache2-mod-php${phpversion}
    fi
    ####/usr/bin/apt-get -qq -y install libapache2-modsecurity
    ####/usr/bin/apt-get -qq -y install modsecurity-crs
    /usr/bin/apt -qq -y install libapache2-mod-fcgid
fi

