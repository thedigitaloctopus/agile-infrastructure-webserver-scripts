#!/bin/sh
########################################################################################
# Description: This script will verify and set a flag to indicate that the application configuration
# has been set up fully and correctly
# Author: Peter Winter
# Date: 04/01/2017
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
#####################################################################################
#####################################################################################
#set -x

/usr/bin/wget --timeout=10 --tries=3 --spider --no-check-certificate https://localhost/index.php

if ( [ "$?" != "0" ] )
then
    /bin/rm ${HOME}/runtime/CONFIG_VERIFIED
fi


if ( [ -f ${HOME}/runtime/CONFIG_VERIFIED ] )
then
    if ( [ ! -f ${HOME}/config/wordpress_config.php ] )
    then
        /bin/cp /var/www/wp-config.php ${HOME}/config/wordpress_config.php
    fi
    if ( [ ! -f ${HOME}/runtime/wordpress_config.php ] )
    then
        /bin/cp /var/www/wp-config.php ${HOME}/runtime/wordpress_config.php
    fi
    exit
fi

#Sleep first so as not to initiate a race condition with the other configuration scripts
/bin/sleep 40

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] )
then
    if ( [ ! -f  ${HOME}/runtime/SSHTUNNELCONFIGURED ] )
    then
        exit
    fi
    host="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    host="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    if ( [ "`/bin/ls ${HOME}/config/databaseip/`" = "" ] )
    then
        exit
    fi
    host="`/bin/ls ${HOME}/config/databaseip | /usr/bin/head -1`"
fi

username="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"
password="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
database="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"


if ( [ -f /var/www/wp-config.php ] &&
    [ "${username}" != "" ] && [ "${password}" != "" ] && [ "${database}" != "" ] && [ "${host}" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${username}`" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${password}`" != "" ] &&
    [ "`/bin/cat /var/www/wp-config.php | /bin/grep ${database}`" != "" ] &&
[ "`/bin/cat /var/www/wp-config.php | /bin/grep ${host}`" != "" ] )
then
    /bin/touch ${HOME}/runtime/CONFIG_VERIFIED
    /usr/bin/rsync -ac /var/www/wp-config.php ${HOME}/config/wordpress_config.php
    /usr/bin/rsync -ac /var/www/wp-config.php ${HOME}/runtime/wordpress_config.php
else
    /bin/rm ${HOME}/runtime/CONFIG_VERIFIED
    /bin/cp /var/www/html/wp-config-sample.php ${HOME}/config/wordpress_config.php
    /bin/cp /var/www/html/wp-config-sample.php ${HOME}/runtime/wordpress_config.php
fi

