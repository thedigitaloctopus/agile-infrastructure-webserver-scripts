#!/bin/sh
######################################################################################
# Description: This script will set up the firewall rules for this webserver for the
# current dns provider. You will  have to add new rules for each new dns provider you
# add to the infrastructure provider you wish to add.
# Date: 16/11/2016
# Author: Peter Winter
#######################################################################################
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
####################################################################################
####################################################################################
#set -x

DNS_CHOICE="`/bin/ls ${HOME}/.ssh/DNSCHOICE:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
then
    #Allow cloudflare to connect to the webserver

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '103.21.244.0/22' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 103.21.244.0/22 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 103.21.244.0/22 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '103.22.200.0/22' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 103.22.200.0/22 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 103.22.200.0/22 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '103.31.4.0/22' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 103.31.4.0/22 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 103.31.4.0/22 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '104.16.0.0/13' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 104.16.0.0/13 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 104.16.0.0/13 to any port 80
    fi
    
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '104.24.0.0/14' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 104.24.0.0/14 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 104.24.0.0/14 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '108.162.192.0/18' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 108.162.192.0/18 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 108.162.192.0/18 to any port 80
    fi

    /bin/sleep 5

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '141.101.64.0/18' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 141.101.64.0/18 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 141.101.64.0/18 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '162.158.0.0/15' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 162.158.0.0/15 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 162.158.0.0/15 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '172.64.0.0/13' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 172.64.0.0/13 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 172.64.0.0/13 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '173.245.48.0/20' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 173.245.48.0/20 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 173.245.48.0/20 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '188.114.96.0/20' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 188.114.96.0/20 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 188.114.96.0/20 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '190.93.240.0/20' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 190.93.240.0/20 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 190.93.240.0/20 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '197.234.240.0/22' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 197.234.240.0/22 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 197.234.240.0/22 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '198.41.128.0/17' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 198.41.128.0/17 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 198.41.128.0/17 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '131.0.72.0/22' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 131.0.72.0/22 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 131.0.72.0/22 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '2400:cb00::/32' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2400:cb00::/32 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2400:cb00::/32 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '2405:8100::/32' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2405:8100::/32 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2405:8100::/32 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '2405:b500::/32' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2405:b500::/32 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2405:b500::/32 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '2606:4700::/32' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2606:4700::/32 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2606:4700::/32 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '2803:f800::/32' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2803:f800::/32 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 2803:f800::/32 to any port 80
    fi

    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep '199.27.128.0/21' | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 199.27.128.0/21 to any port 443
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from 199.27.128.0/21 to any port 80
    fi
fi

if ( [ "${DNS_CHOICE}" = "rackspace" ] )
then
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow 443/tcp
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow 80/tcp
fi

if ( [ "${DNS_CHOICE}" = "digitalocean" ] )
then
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow 443/tcp
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow 80/tcp
fi
