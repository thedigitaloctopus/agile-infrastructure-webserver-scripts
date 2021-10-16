#!/bin/sh
################################################################################
# Description: This script will install a joomla configuration. There creates a
# default configuration to bundled with the  sourcecode which is used and customised
# for the particular deployment each time.
# Author: Peter Winter
# Date: 04/01/2017
#################################################################################
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
################################################################################
################################################################################
#set -x

#We use the shared directory to enable us to have the same configuration for all webservers in our fleet.
#So, this script is called once on reboot of the machine and it basically waits until the configuration
#directory is mounted and the credentials are available. If they are then it's like woohoo, we can set up
#our shared configuration

while ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] || [ ! -f ${HOME}/config/credentials/shit ] )
do
    /bin/sleep 10
done

#Because we only have to do this once for our entire deployment, we can check to see if we have already done this
#via another server. If we have, then we are already set up and can bail

if ( [ -f ${HOME}/config/APPLICATION_CONFIGURATION_PREPARED ] )
then
    exit
fi

#A default joomla download has a sample configuration.php file in its installation directory. This should be taken
# care of by the InitialiseVirginApplication script, but, there's no harm doing it again here just in case. What we can do is copy
#this file to be our main configuration.php file and modify it according to the credentials that have been set later on.
#These credentials will be modified by the script called ConfigureDBAccess.sh
if ( [ -f /var/www/html/installation/configuration.php-dist ] )
then
    /bin/cp /var/www/html/installation/configuration.php-dist /var/www/html/configuration.php.default
fi

#This will fill out the symlink we created earlier. We know that our configuration directory must be mounted
if ( [ -f /var/www/html/configuration.php.default ] )
then
    /bin/cp /var/www/html/configuration.php.default ${HOME}/runtime/joomla_configuration.php

    count="0"
    while ( [ "${count}" -lt "5" ] && [ "`/usr/bin/diff /var/www/html/configuration.php.default ${HOME}/config/joomla_configuration.php`" != "" ] )
    do
        /bin/cp /var/www/html/configuration.php.default ${HOME}/config/joomla_configuration.php
        count="`/usr/bin/expr ${count} + 1`"
        /bin/sleep 5
    done
fi

if ( [ -f ${HOME}/config/credentials/shit ] && [ ! -f ${HOME}/config/APPLICATION_CONFIGURATION_PREPARED ] )
then
    /bin/sed -i "/\$cachetime /c\        public \$cachetime = \'30\';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'file\';" ${HOME}/runtime/joomla_configuration.php
    /bin/cp ${HOME}/runtime/joomla_configuration.php ${HOME}/config/joomla_configuration.php
    count="0"
    while ( [ "${count}" -lt "5" ] && [ "`/usr/bin/diff {HOME}/runtime/joomla_configuration.php ${HOME}/config/joomla_configuration.php`" != "" ] )
    do
        /bin/cp ${HOME}/runtime/joomla_configuration.php ${HOME}/config/joomla_configuration.php
        count="`/usr/bin/expr ${count} + 1`"
        /bin/sleep 5
    done
    if ( [ "${count}" = "5" ] )
    then
        exit
    fi

    /bin/chmod 600 ${HOME}/config/joomla_configuration.php
    /bin/touch ${HOME}/config/APPLICATION_CONFIGURATION_PREPARED
    /bin/echo "1"
fi
