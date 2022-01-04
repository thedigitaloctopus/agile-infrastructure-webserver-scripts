
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

BUILDOSVERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOSVERSION'`"

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    /usr/bin/systemctl disable --now apache2
    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
    then
        # ${HOME}/installscripts/Update.sh ${BUILDOS}
         ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}

         if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:source:modsecurity'`" = "1" ] )
         then
             ${HOME}/installscripts/nginx/BuildNginxFromSource.sh Ubuntu modsecurity
         else
             ${HOME}/installscripts/nginx/BuildNginxFromSource.sh Ubuntu
         fi 
         
         /bin/touch /etc/nginx/BUILT_FROM_SOURCE
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:repo'`" = "1" ] )
    then
        /usr/bin/curl http://nginx.org/keys/nginx_signing.key | /usr/bin/apt-key add -
      #  ${HOME}/installscripts/Update.sh ${BUILDOS}
        ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
       /usr/bin/apt-get -qq install nginx
        /bin/systemctl unmask nginx.service
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:repo:modsecurity'`" = "1" ] )
        then
            ${HOME}/installscripts/nginx/BuildModsecurityForRepo.sh
        fi
        /bin/touch /etc/nginx/BUILT_FROM_REPO
    fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    /usr/bin/systemctl disable --now apache2
    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:source'`" = "1" ] )
    then
       # ${HOME}/installscripts/Update.sh ${BUILDOS}
        ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:source:modsecurity'`" = "1" ] )
        then
            ${HOME}/installscripts/nginx/BuildNginxFromSource.sh Debian modsecurity
        else
            ${HOME}/installscripts/nginx/BuildNginxFromSource.sh Debian
        fi
        
        /bin/touch /etc/nginx/BUILT_FROM_SOURCE
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:repo'`" = "1" ] )
    then    
        /usr/bin/curl http://nginx.org/keys/nginx_signing.key | /usr/bin/apt-key add -
      #  ${HOME}/installscripts/Update.sh ${BUILDOS}
        ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
        /usr/bin/apt-get -qq install nginx
        /bin/systemctl unmask nginx.service
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'NGINX:repo:modsecurity'`" = "1" ] )
        then
            ${HOME}/installscripts/nginx/BuildModsecurityForRepo.sh
        fi
        /bin/touch /etc/nginx/BUILT_FROM_REPO
    fi
fi

