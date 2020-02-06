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

phpversion="`/bin/ls ${HOME}/.ssh/PHP_VERSION:* | /usr/bin/awk -F':' '{print $NF}'`"
if ( [ "${1}" != "" ] )
then
    BUILDOS="${1}"
fi

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    /usr/bin/add-apt-repository ppa:ondrej/php
    /usr/bin/apt -qq -y update
    #removed php-mcrypt php7.2
    /usr/bin/apt-get -qq -y install php${phpversion}-fpm php${phpversion}-cli php${phpversion}-common php${phpversion}-dev  php${phpversion}-json php${phpversion}-opcache php${phpversion}-mysql php${phpversion}-phpdbg php${phpversion}-mbstring php${phpversion}-gd php${phpversion}-imap php${phpversion}-ldap php${phpversion}-pgsql php${phpversion}-pspell php${phpversion}-tidy php${phpversion}-intl php${phpversion}-gd php${phpversion}-curl php${phpversion}-zip php${phpversion}-xml php-mysql php${phpversion}-memcache php${phpversion}-redis

fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    #removed php-mcrypt
    /usr/bin/apt -qq -y install apt-transport-https lsb-release ca-certificates
    /usr/bin/wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    /bin/sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
    /usr/bin/apt -qq -y update
    /usr/bin/apt-get -qq -y install php${phpversion}-fpm php${phpversion}-cli php${phpversion}-common php${phpversion}-dev  php${phpversion}-json php${phpversion}-opcache php${phpversion}-mysql php${phpversion}-phpdbg php${phpversion}-mbstring php${phpversion}-gd php${phpversion}-imap php${phpversion}-ldap php${phpversion}-pgsql php${phpversion}-pspell php${phpversion}-tidy php${phpversion}-intl php${phpversion}-gd php${phpversion}-curl php${phpversion}-zip php${phpversion}-xml php-mysql php${phpversion}-memcache php${phpversion}-redis
fi


