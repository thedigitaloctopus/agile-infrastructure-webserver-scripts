#!/bin/sh
####################################################################################
# Description: This will share the joomla config file between webservers
# Date: 21/11/2016
# Author: Peter Winter
####################################################################################
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
#################################################################################
#################################################################################
#set -x

if ( [ ! -f ${HOME}/runtime/joomla_configuration.php ] )
then
    if ( [ -f /var/www/html/installation/configuration.php-dist ] )
    then
        /bin/cp /var/www/html/installation/configuration.php-dist /var/www/html/configuration.php.default
    fi
    /bin/cp /var/www/html/configuration.php.default ${HOME}/runtime/joomla_configuration.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
fi


if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "joomla_configuration.php"`" = "0" ] )
then
    if ( [ -f /var/www/html/installation/configuration.php-dist ] )
    then
        /bin/cp /var/www/html/installation/configuration.php-dist /var/www/html/configuration.php.default
    fi
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/www/html/configuration.php.default ${HOME}/config/joomla_configuration.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
fi

if ( [ ! -f /var/www/html/configuration.php ] )
then
    if ( [ -f /var/www/html/installation/configuration.php-dist ] )
    then
        /bin/cp /var/www/html/installation/configuration.php-dist /var/www/html/configuration.php.default
    fi
    /bin/cp /var/www/html/configuration.php.default /var/www/html/configuration.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
fi

ip="`${HOME}/providerscripts/utilities/GetIP.sh`"
global_config_updated="0"



if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "GLOBAL_CONFIG_UPDATE.${ip}"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/joomla_configuration.php
    /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
    /bin/sleep 40
elif ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh GLOBAL_CONFIG_UPDATE.*`" != "" ] )
then
    /bin/sleep 20 
    global_config_updated="1"
fi

runtime_md5="`/usr/bin/md5sum ${HOME}/runtime/joomla_configuration.php | /usr/bin/awk '{print $1}'`"
${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php /tmp/joomla_configuration.php
config_md5="`/usr/bin/md5sum /tmp/joomla_configuration.php | /usr/bin/awk '{print $1}'`"
main_md5="`/usr/bin/md5sum /var/www/html/configuration.php | /usr/bin/awk '{print $1}'`"

updated="0"

if ( [ "${runtime_md5}" = "${config_md5}" ] && [ "${config_md5}" = "${main_md5}" ] )
then
    updated="0"
else
    updated="1"
fi

changed=""

if ( [ "${updated}" = "1" ] )
then
    if ( [ "`/usr/bin/find ${HOME}/config/joomla_configuration.php -mmin -2`" != "" ] )
    then
        #This check is needed so we don't accidentally update the config file and push it to all our webservers
        #We have to explicitly create the GLOBAL_CONFIG_UPDATE file to do that. 
        if ( [ "${global_config_updated}" = "1" ] )
        then
            changed="config"
        fi
    fi
    if ( [ "`/usr/bin/find /var/www/html/configuration.php -mmin -2`" != "" ] )
    then
        changed="main"
    fi
    if ( [ "`/usr/bin/find ${HOME}/runtime/joomla_configuration.php -mmin -2`" != "" ] )
    then
        changed="runtime"
    fi
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTOSCALED`" = "1" ] && [ ! -f ${HOME}/runtime/PROCESSED_INITIAL_CONFIG ] )
    then
        changed="config"
        /bin/touch ${HOME}/runtime/PROCESSED_INITIAL_CONFIG
    fi
fi

/bin/sleep 10

if ( [ "${changed}" = "config" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ${HOME}/config/joomla_configuration.php ${HOME}/runtime/joomla_configuration.php 
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php /var/www/html/configuration.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
fi
if ( [ "${changed}" = "main" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/www/html/configuration.php ${HOME}/config/joomla_configuration.php
    /bin/cp /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
fi
if ( [ "${changed}" = "runtime" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/joomla_configuration.php ${HOME}/config/joomla_configuration.php
    /bin/cp ${HOME}/runtime/joomla_configuration.php /var/www/html/configuration.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "GLOBAL_CONFIG_UPDATE.${ip}"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "GLOBAL_CONFIG_UPDATE.${ip}"
fi

