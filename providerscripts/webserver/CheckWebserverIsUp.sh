#!/bin/sh
#########################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Check if the webserver is running
#########################################################################################
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
#########################################################################################
#########################################################################################
#set -x

webserver_type="${1}"
phpversion="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"


if ( [ "${webserver_type}" = "APACHE" ] )
then
    if ( [ "`/usr/bin/pgrep php`" = "" ] )
    then
        /usr/sbin/service php${phpversion}-fpm restart || . /etc/apache2/conf/envvars && /etc/apache2/bin/apachectl -k restart    
    fi
    if ( [ "`/usr/bin/pgrep apache`" = "" ] )
    then
        /usr/sbin/service apache2 restart
    fi
fi
if ( [ "${webserver_type}" = "NGINX" ] )
then
    if ( [ "`/usr/bin/pgrep php`" = "" ] )
    then
        /usr/sbin/service php${phpversion}-fpm restart
    fi
    if ( [ "`/usr/bin/pgrep nginx`" = "" ] )
    then
        /usr/sbin/service nginx start
    fi
fi
if ( [ "${webserver_type}" = "LIGHTTPD" ] )
then
    if ( [ "`/usr/bin/pgrep php`" = "" ] )
    then
        /usr/sbin/service php${phpversion}-fpm restart
    fi
    if ( [ "`/usr/bin/pgrep lighttpd`" = "" ] )
    then
        /usr/sbin/service lighttpd start
    fi
fi
