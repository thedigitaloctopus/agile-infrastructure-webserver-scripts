
#!/bin/sh
######################################################################################################
# Description: This script will install the nginx webserver
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

BUILDOSVERSION="`/bin/ls ${HOME}/.ssh/BUILDOSVERSION:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    ##############################################################
    #If you want to build nginx from source, uncomment these lines
    ##############################################################
  #  ${HOME}/installscripts/Update.sh ${BUILDOS}
  #  ${HOME}/installscripts/nginx/BuildNginxFromSource.sh Ubuntu
    
    #####################################################################
    #if you want to build nginx from repos, uncomment these lines instead
    #####################################################################
    /usr/bin/systemctl disable --now apache2
    /usr/bin/curl http://nginx.org/keys/nginx_signing.key | /usr/bin/apt-key add -
    ${HOME}/installscripts/Update.sh ${BUILDOS}
    /usr/bin/apt-get -qq install nginx
    /bin/systemctl unmask nginx.service
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    if ( [ "${BUILDOSVERSION}" = "9" ] )
    then
        /bin/echo "deb http://packages.dotdeb.org stretch all
        deb-src http://packages.dotdeb.org stretch all" >> /etc/apt/sources.list
    fi
    ########################################################
    #If you want to build from source, uncomment these lines
    ########################################################
   # ${HOME}/installscripts/Update.sh ${BUILDOS}
   # ${HOME}/installscripts/nginx/BuildNginxFromSource.sh Debian
    
    ###############################################################
    #If you want to build from repos, uncomment these lines instead
    ###############################################################
     /usr/bin/curl http://nginx.org/keys/nginx_signing.key | /usr/bin/apt-key add -
     ${HOME}/installscripts/Update.sh ${BUILDOS}
     /usr/bin/apt-get -qq install nginx
     /bin/systemctl unmask nginx.service
fi

