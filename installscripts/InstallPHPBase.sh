#!/bin/sh
######################################################################################################
# Description: This script will install the php base
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
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "0" ] )
then
    exit
fi

BUILDOSVERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOSVERSION'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"

if ( [ "${1}" != "" ] )
then
    BUILDOS="${1}"
fi

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    if ( [ "${BUILDOSVERSION}" = "20.04" ] )
    then
        /usr/bin/add-apt-repository -y ppa:ondrej/php
       # ${HOME}/installscripts/Update.sh ${BUILDOS}
        ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}

        installed_php_version="`/usr/bin/php -v | /bin/grep "^PHP" | /usr/bin/awk '{print $2}' | /usr/bin/awk -F'.' '{print $1,$2}' | /bin/sed 's/ /\./g'`"
        if ( [ "${installed_php_version}" != "${PHP_VERSION}" ] )
        then
            /usr/bin/apt-get -qq -y purge php*
            /usr/bin/apt-get -qq -y autoclean
            /usr/bin/apt-get -qq -y autoremove
        fi
        
        modules="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PHP" "stripped" | /bin/sed 's/:/ /g'`"
    
        for module in ${modules}
        do
            /usr/bin/apt-get -qq -y install php${PHP_VERSION}-${module}
        done
          
       /usr/bin/apt-get -qq -y install php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-gmp  php${PHP_VERSION}-xmlrpc php${PHP_VERSION}-soap php${PHP_VERSION}-dev php${PHP_VERSION}-mysqli php${PHP_VERSION}-phpdbg php${PHP_VERSION}-mbstring php${PHP_VERSION}-gd php${PHP_VERSION}-imap php${PHP_VERSION}-ldap php${PHP_VERSION}-pgsql php${PHP_VERSION}-pspell php${PHP_VERSION}-tidy php${PHP_VERSION}-intl php${PHP_VERSION}-gd php${PHP_VERSION}-curl php${PHP_VERSION}-zip php${PHP_VERSION}-xml php${PHP_VERSION}-imagick php${PHP_VERSION}-ssh2 php${PHP_VERSION}-sqlite3
    
       if ( [ "`/bin/echo ${PHP_VERSION} | /bin/grep '7\.'`" != "" ] )
       then
           /usr/bin/apt-get -qq -y install php${PHP_VERSION}-json
       fi
   fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    #removed php-mcrypt
    /usr/bin/apt-get -qq -y install apt-transport-https lsb-release ca-certificates
    /usr/bin/wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    /bin/sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

   # ${HOME}/installscripts/Update.sh ${BUILDOS}    
    ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}

    installed_php_version="`/usr/bin/php -v | /bin/grep "^PHP" | /usr/bin/awk '{print $2}' | /usr/bin/awk -F'.' '{print $1,$2}' | /bin/sed 's/ /\./g'`"
      
    if ( [ "${installed_php_version}" != "${PHP_VERSION}" ] )
    then
        /usr/bin/apt-get -qq -y purge php*
        /usr/bin/apt-get -qq -y autoclean
        /usr/bin/apt-get -qq -y autoremove
    fi
    
    modules="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PHP" "stripped" | /bin/sed 's/:/ /g'`"
    
    for module in ${modules}
    do
        /usr/bin/apt-get -qq -y install php${PHP_VERSION}-${module}
    done

    #/usr/bin/apt-get -qq -y install php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-gmp php${PHP_VERSION}-xmlrpc php${PHP_VERSION}-soap php${PHP_VERSION}-dev php${PHP_VERSION}-mysqli php${PHP_VERSION}-phpdbg php${PHP_VERSION}-mbstring php${PHP_VERSION}-gd php${PHP_VERSION}-imap php${PHP_VERSION}-ldap php${PHP_VERSION}-pgsql php${PHP_VERSION}-pspell php${PHP_VERSION}-tidy php${PHP_VERSION}-intl php${PHP_VERSION}-gd php${PHP_VERSION}-curl php${PHP_VERSION}-zip php${PHP_VERSION}-xml php${PHP_VERSION}-imagick php${PHP_VERSION}-ssh2 php${PHP_VERSION}-sqlite3

    if ( [ "`/bin/echo ${PHP_VERSION} | /bin/grep '7\.'`" != "" ] )
    then
        /usr/bin/apt-get -qq -y install php${PHP_VERSION}-json
    fi
fi
