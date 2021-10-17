#!/bin/sh
####################################################################################
# Description: This will share the wordpress config file between webservers
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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTOSCALED`" = "1" ] )
then
    if ( [ ! -f ${HOME}/runtime/USED_CONFIG_AS_AUTHORITATIVE ] )
    then
        /bin/cp ${HOME}/config/joomla_configuration.php ${HOME}/runtime/joomla_configuration.php
        /bin/touch ${HOME}/runtime/USED_CONFIG_AS_AUTHORITATIVE
    fi
fi

if ( [ ! -f ${HOME}/runtime/wordpress_config.php  ] )
then
    if ( [ -f /var/www/html/wp-config-sample.php ] )
    then
        /bin/cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php.default
    fi
    /bin/cp /var/www/html/wp-config.php.default  ${HOME}/runtime/wordpress_config.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
fi

if ( [ ! -f ${HOME}/config/wordpress_config.php  ] )
then
    if ( [ -f /var/www/html/wp-config-sample.php ] )
    then
        /bin/cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php.default
    fi
    /bin/cp /var/www/html/wp-config.php.default  ${HOME}/config/wordpress_config.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
fi

if ( [ ! -f /var/www/wp-config.php ] )
then
    if ( [ -f /var/www/html/wp-config-sample.php ] )
    then
        /bin/cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php.default
    fi
    /bin/cp /var/www/html/wp-config.php.default  /var/www/wp-config.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
fi

if ( [ -f ${HOME}/config/GLOBAL_CONFIG_UPDATE ] )
then
    /bin/cp ${HOME}/config/wordpress_config.php ${HOME}/runtime/wordpress_config.php 
    /bin/cp ${HOME}/runtime/wordpress_config.php  /var/www/wp-config.php
    /bin/sleep 30 
    /bin/rm ${HOME}/config/GLOBAL_CONFIG_UPDATE 
fi

runtime_md5="`/usr/bin/md5sum ${HOME}/runtime/wordpress_config.php | /usr/bin/awk '{print $1}'`"
config_md5="`/usr/bin/md5sum ${HOME}/config/wordpress_config.php | /usr/bin/awk '{print $1}'`"
main_md5="`/usr/bin/md5sum /var/www/wp-config.php | /usr/bin/awk '{print $1}'`"

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
    if ( [ "`/usr/bin/find ${HOME}/config/wordpress_config.php -mmin -1`" != "" ] )
    then
        #This check is needed so we don't accidentally update the config file and push it to all our webservers
        #We have to explicitly create the GLOBAL_CONFIG_UPDATE file to do that. 
        if ( [ -f ${HOME}/config/GLOBAL_CONFIG_UPDATE ] )
        then
            changed="config"
        fi
    fi
    if ( [ "`/usr/bin/find /var/www/wp-config.php -mmin -1`" != "" ] )
    then
        changed="main"
    fi
    if ( [ "`/usr/bin/find ${HOME}/runtime/wordpress_config.php -mmin -1`" != "" ] )
    then
        changed="runtime"
    fi
fi

/bin/sleep 10

if ( [ "${changed}" = "config" ] )
then
    /bin/cp ${HOME}/config/wordpress_config.php ${HOME}/runtime/wordpress_config.php
    /bin/cp ${HOME}/config/wordpress_config.php /var/www/wp-config.php
fi
if ( [ "${changed}" = "main" ] )
then
    /bin/cp /var/www/wp-config.php ${HOME}/config/wordpress_config.php
    /bin/cp /var/www/wp-config.php ${HOME}/runtime/wordpress_config.php
fi
if ( [ "${changed}" = "runtime" ] )
then
    /bin/cp ${HOME}/runtime/wordpress_config.php ${HOME}/config/wordpress_config.php
    /bin/cp ${HOME}/runtime/wordpress_config.php /var/www/wp-config.php
fi
