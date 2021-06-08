#!/bin/sh
#############################################################################################
# Description: This script will setup the credentials for "basic auth" provided by your webserver.
# You can find out about "basic auth" here:
# https://www.digitalocean.com/community/tutorials/how-to-set-up-basic-http-authentication-with-nginx-on-ubuntu-14-04
# The way it works is it looks in your database for your user's username and password and uses them
# as the credentials for the basic auth process. This script is called from cron on a minute by minute basis 
# to check that the basic auth credentials are up to date with the joomla credentials.
# Users will have to enter their credentials twice. The first time, it protects the webroot, so anyone
# without a password can't get at thw webroot and the second time it is for authentication to the joomla CMS.
# It is the same username and password in each case. 
# Author: Peter Winter
# Date: 08/06/2021
#############################################################################################
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
##########################################################################################
##########################################################################################
#set -x

if ( [ -f ${HOME}/.ssh/WEBSERVERCHOICE:NGINX ] )
then
    if ( [ ! -f /etc/nginx/.htpasswd ] )
    then
       /bin/touch /etc/nginx/.htpasswd
    fi
elif ( [ -f ${HOME}/.ssh/WEBSERVERCHOICE:APACHE ] )
then
    if ( [ ! -f /etc/apache2/.htpasswd ] )
    then
       /bin/touch /etc/apache2/.htpasswd
    fi
fi

user_table_name="`/bin/cat /var/www/html/dpb.dat`_users"
usernames="`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "select name from ${user_table_name}" raw`"
passwords="`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "select password from ${user_table_name}" raw`"

count="0"
for username in ${usernames}
do
    count="`/usr/bin/expr ${count} + 1`"
    password="`/bin/echo "${passwords}" | /usr/bin/cut -d " " -f ${count}`"
    matchablepassword="`/bin/echo ${password} | /bin/sed 's/$/\$/g'`"
    
    if ( [ -f ${HOME}/.ssh/WEBSERVERCHOICE:NGINX ] )
    then
        if ( [ "`/bin/cat /tmp/credentials | /bin/grep "${username}"`" = "" ] || [ "`/bin/cat /tmp/credentials | /bin/grep ${matchablepassword}`" = "" ] )
        then
            /bin/sed -i "/${username}/d" /etc/nginx/.htpasswd
            /bin/echo "${username}:${password}" >> /etc/nginx/.htpasswd
        fi
    elif ( [ -f ${HOME}/.ssh/WEBSERVERCHOICE:APACHE ] )
    then
        if ( [ "`/bin/cat /tmp/credentials | /bin/grep "${username}"`" = "" ] || [ "`/bin/cat /tmp/credentials | /bin/grep ${matchablepassword}`" = "" ] )
        then
            /bin/sed -i "/${username}/d" /etc/apache2/.htpasswd
            /bin/echo "${username}:${password}" >> /etc/apache2/.htpasswd
        fi
    fi
done
