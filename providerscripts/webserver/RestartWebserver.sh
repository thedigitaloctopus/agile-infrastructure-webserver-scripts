#!/bin/sh
########################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script restarts the webserver
########################################################################################
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
#######################################################################################
#######################################################################################
#set -x

WEBSERVERCHOICE="`/bin/ls ${HOME}/.ssh/WEBSERVERCHOICE:* | /usr/bin/awk -F':' '{print $NF}'`"
phpversion="`/bin/ls ${HOME}/.ssh/PHP_VERSION:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${WEBSERVERCHOICE}" = "NGINX" ] )
then
    /usr/sbin/service php${phpversion}-fpm restart
    /usr/sbin/service nginx restart
fi
if ( [ "${WEBSERVERCHOICE}" = "APACHE" ] )
then
    /usr/sbin/service php${phpversion}-fpm restart
    /usr/sbin/service apache2 restart
fi
if ( [ "${WEBSERVERCHOICE}" = "LIGHTTPD" ] )
then
    /usr/sbin/service php${phpversion}-fpm restart
    /usr/sbin/service lighttpd restart
fi
