#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will perform a rudimentary configuration of your chosen
# webserver. You are welcome to modify it to your own requirements.
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
##################################################################################
##################################################################################
#set -x

webserver_type="${1}"
website_name="${2}"
website_url="${3}"
SERVER_USER="`/bin/ls ${HOME}/.ssh/SERVERUSER:* | /usr/bin/awk -F':' '{print $NF}'`"


if ( [ "${webserver_type}" = "NGINX" ] )
then
    #install nginx
    . ${HOME}/providerscripts/webserver/configuration/InstallNginx.sh

    #customise by application
    . ${HOME}/providerscripts/webserver/configuration/CustomiseNginxByApplication.sh
    #Activate it
    /bin/rm /etc/nginx/sites-available/defau* 2>/dev/null

    if ( [ ! -d /etc/nginx/sites-enabled ] )
    then
        /bin/mkdir /etc/nginx/sites-enabled
    fi

    /bin/ln -s /etc/nginx/sites-available/${website_name} /etc/nginx/sites-enabled/${website_name}
fi

if ( [ "${webserver_type}" = "APACHE" ] )
then
    #install Apache
    . ${HOME}/providerscripts/webserver/configuration/InstallApache.sh
    #customise by application
    . ${HOME}/providerscripts/webserver/configuration/CustomiseApacheByApplication.sh
    #Activate it
    /bin/echo "@reboot /bin/sleep 60 && /etc/init.d/apache2 restart" >> /var/spool/cron/crontabs/${SERVER_USER}
fi
if ( [ "${webserver_type}" = "LIGHTTPD" ] )
then
    #install lighthttpd
    . ${HOME}/providerscripts/webserver/configuration/InstallLighttpd.sh
    #customise by application
    . ${HOME}/providerscripts/webserver/configuration/CustomiseLighttpdByApplication.sh
fi
