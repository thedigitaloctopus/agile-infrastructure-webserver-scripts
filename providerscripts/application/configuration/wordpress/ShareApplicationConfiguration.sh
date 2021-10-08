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

# You can manually update the configuration file for your application under ${HOME}/config/wordpress_config.php
# and create an empty file ${HOME}/config/GLOBAL_CONFIG_UPDATE which will indicate that these changes will need 
#to be pushed to each webserver. In this way, you can update all your webserver configurations
#if ( [ -f ${HOME}/config/GLOBAL_CONFIG_UPDATE ] && [ ! -f ${HOME}/runtime/GLOBAL_CONFIG_UPDATE_PROCESSED ] )
#then
#    /bin/cp ${HOME}/config/wordpress_config.php ${HOME}/runtime/wordpress_config.php
#    /bin/cp ${HOME}/runtime/wordpress_config.php /var/www/wp-config.php
#    /bin/touch ${HOME}/runtime/GLOBAL_CONFIG_UPDATE_PROCESSED 
#    /bin/sleep 300
#    if ( [ -f ${HOME}/config/GLOBAL_CONFIG_UPDATE ] )
#    then
#        /bin/rm ${HOME}/config/GLOBAL_CONFIG_UPDATE 
#    fi
#    /bin/rm ${HOME}/runtime/GLOBAL_CONFIG_UPDATE_PROCESSED
#fi

#if ( [ -f ${HOME}/runtime/CONFIG_VERIFIED ] && [ ! -f ${HOME}/runtime/CONFIG_UPDATING ] )
#then
#    exit
#fi

#Note the config file is outside the webroot. This is because wordpress checks one level higher and it's safer to have it there.
if ( [ -f /var/www/wp-config.php ] && [ -f /var/www/html/wp-config.php ] )
then
    /bin/rm /var/www/html/wp-config.php
fi

/usr/bin/rsync -au ${HOME}/runtime/wordpress_config.php /var/www/wp-config.php
/bin/chown www-data.www-data /var/www/wp-config.php
/bin/chmod 400 /var/www/wp-config.php

/bin/sleep 10

/usr/bin/rsync -au /var/www/wp-config.php ${HOME}/config/wordpress_config.php
/usr/bin/rsync -au /var/www/wp-config.php ${HOME}/runtime/wordpress_config.php

