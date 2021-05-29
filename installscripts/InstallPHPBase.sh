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
if ( [ ! -f ${HOME}/.ssh/APPLICATIONLANGUAGE:PHP ] )
then
    exit
fi

BUILDOSVERSION="`/bin/ls ${HOME}/.ssh/BUILDOSVERSION:* | /usr/bin/awk -F':' '{print $NF}'`"

phpversion="`/bin/ls ${HOME}/.ssh/PHP_VERSION:* | /usr/bin/awk -F':' '{print $NF}'`"
if ( [ "${1}" != "" ] )
then
    BUILDOS="${1}"
fi

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    if ( [ "${BUILDOSVERSION}" = "18.04" ] )
    then
        /usr/bin/add-apt-repository -y ppa:ondrej/php
        ${HOME}/installscripts/Update.sh ${BUILDOS}

        #removed php-mcrypt php7.2        
      #  /usr/bin/apt-get -qq -y install php${phpversion}-fpm php${phpversion}-cli php${phpversion}-gmp php${phpversion}-common php${phpversion}-dev php${phpversion}-opcache php${phpversion}-mysqli php${phpversion}-phpdbg php${phpversion}-mbstring php${phpversion}-gd php${phpversion}-imap php${phpversion}-ldap php${phpversion}-pgsql php${phpversion}-pspell php${phpversion}-tidy php${phpversion}-intl php${phpversion}-gd php${phpversion}-curl php${phpversion}-zip php${phpversion}-xml openssl php-imagick php-json php-ssh2 php${phpversion}-sqlite3

        #If php did not install at the version we chose for example, if you chose to install php7.4 on ubuntu 19.04 it will not install
        #This is  potential configuration oversight if someone doesn't realise what versions of php are supported by a particular OS
        #So, in this case, check if php has been installed at our desired version and if it isn't do the best that we can
        installedphpversion="`/usr/bin/php -v | /bin/grep "^PHP" | /usr/bin/awk '{print $2}' | /usr/bin/awk -F'.' '{print $1,$2}' | /bin/sed 's/ /\./g'`"

        if ( [ "${installedphpversion}" != "${phpversion}" ] )
        then
            /usr/bin/apt-get -qq -y purge php*
            /usr/bin/apt-get -qq -y autoclean
            /usr/bin/apt-get -qq -y autoremove
        fi
        /usr/bin/apt-get -qq -y install php-fpm php-cli php-common php-dev php-json php-opcache php-mysqli php-phpdbg php-mbstring php-gd php-imap php-ldap php-pgsql php-pspell php-tidy php-intl php-gd php-curl php-zip php-xml
    elif ( [ "${BUILDOSVERSION}" = "20.04" ] )
    then
        /usr/bin/add-apt-repository -y ppa:ondrej/php
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        
        installedphpversion="`/usr/bin/php -v | /bin/grep "^PHP" | /usr/bin/awk '{print $2}' | /usr/bin/awk -F'.' '{print $1,$2}' | /bin/sed 's/ /\./g'`"
        if ( [ "${installedphpversion}" != "${phpversion}" ] )
        then
            /usr/bin/apt-get -qq -y purge php*
            /usr/bin/apt-get -qq -y autoclean
            /usr/bin/apt-get -qq -y autoremove
            #/usr/bin/apt-get -qq -y install php-fpm php-cli php-common php-dev php-opcache php-mysqli php-phpdbg php-mbstring php-gd php-imap php-ldap php-pgsql php-pspell php-tidy php-intl php-gd php-curl php-zip php-xml
        fi
        
       #/usr/bin/apt-get -qq -y install php${phpversion}-fpm php${phpversion}-cli php${phpversion}-gmp php${phpversion}-common php${phpversion}-dev php${phpversion}-opcache php${phpversion}-mysqli php${phpversion}-phpdbg php${phpversion}-mbstring php${phpversion}-gd php${phpversion}-imap php${phpversion}-ldap php${phpversion}-pgsql php${phpversion}-pspell php${phpversion}-tidy php${phpversion}-intl php${phpversion}-gd php${phpversion}-curl php${phpversion}-zip php${phpversion}-xml php${phpversion}-imagick php-json php${phpversion}-ssh2 php${phpversion}-sqlite3
      
       /usr/bin/apt-get -qq -y install php${phpversion}-fpm php${phpversion}-cli php${phpversion}-gmp php${phpversion}-dev php${phpversion}-mysqli php${phpversion}-phpdbg php${phpversion}-mbstring php${phpversion}-gd php${phpversion}-imap php${phpversion}-ldap php${phpversion}-pgsql php${phpversion}-pspell php${phpversion}-tidy php${phpversion}-intl php${phpversion}-gd php${phpversion}-curl php${phpversion}-zip php${phpversion}-xml php${phpversion}-imagick php${phpversion}-ssh2 php${phpversion}-sqlite3
    
       if ( [ "`/bin/echo ${PHP_VERSION} | /bin/grep '7\.'`" != "" ] )
       then
           /usr/bin/apt-get -qq -y install php${phpversion}-json
       fi
   fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    #removed php-mcrypt
    /usr/bin/apt -qq -y install apt-transport-https lsb-release ca-certificates
    /usr/bin/wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    /bin/sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

    ${HOME}/installscripts/Update.sh ${BUILDOS}    

    #If php did not install at the version we chose for example, if you chose to install php7.4 on ubuntu 19.04 it will not install
    #This is  potential configuration oversight if someone doesn't realise what versions of php are supported by a particular OS
    #So, in this case, check if php has been installed at our desired version and if it isn't do the best that we can
    installedphpversion="`/usr/bin/php -v | /bin/grep "^PHP" | /usr/bin/awk '{print $2}' | /usr/bin/awk -F'.' '{print $1,$2}' | /bin/sed 's/ /\./g'`"
    
    
    if ( [ "${installedphpversion}" != "${phpversion}" ] )
    then
        /usr/bin/apt-get -qq -y purge php*
        /usr/bin/apt-get -qq -y autoclean
        /usr/bin/apt-get -qq -y autoremove
        #/usr/bin/apt-get -qq -y install php-fpm php-cli php-common php-dev php-opcache php-mysqli php-phpdbg php-mbstring php-gd php-imap php-ldap php-pgsql php-pspell php-tidy php-intl php-gd php-curl php-zip php-xml
    fi

    #if ( [ "${installedphpversion}" != "${phpversion}" ] )
    #then
    #   /bin/rm -r /etc/php/${installedphpversion}
    #   /usr/bin/apt-get -qq -y install php-fpm php-cli php-common php-dev php-opcache php-mysqli php-phpdbg php-mbstring php-gd php-imap php-ldap php-pgsql php-pspell php-tidy php-intl php-gd php-curl php-zip php-xml
    #else
    #/usr/bin/apt-get -qq -y install php${phpversion}-fpm php${phpversion}-cli php${phpversion}-gmp php${phpversion}-common php${phpversion}-dev php${phpversion}-opcache php${phpversion}-mysqli php${phpversion}-phpdbg php${phpversion}-mbstring php${phpversion}-gd php${phpversion}-imap php${phpversion}-ldap php${phpversion}-pgsql php${phpversion}-pspell php${phpversion}-tidy php${phpversion}-intl php${phpversion}-gd php${phpversion}-curl php${phpversion}-zip php${phpversion}-xml php${phpversion}-imagick php-json php${phpversion}-ssh2 php${phpversion}-sqlite3
    /usr/bin/apt-get -qq -y install php${phpversion}-fpm php${phpversion}-cli php${phpversion}-gmp php${phpversion}-dev php${phpversion}-mysqli php${phpversion}-phpdbg php${phpversion}-mbstring php${phpversion}-gd php${phpversion}-imap php${phpversion}-ldap php${phpversion}-pgsql php${phpversion}-pspell php${phpversion}-tidy php${phpversion}-intl php${phpversion}-gd php${phpversion}-curl php${phpversion}-zip php${phpversion}-xml php${phpversion}-imagick php${phpversion}-ssh2 php${phpversion}-sqlite3

    if ( [ "`/bin/echo ${PHP_VERSION} | /bin/grep '7\.'`" != "" ] )
    then
        /usr/bin/apt-get -qq -y install php${phpversion}-json
    fi
   #fi
fi


