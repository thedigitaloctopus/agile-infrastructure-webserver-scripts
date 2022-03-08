#!/bin/sh
#######################################################################################
# Description: This script will install a drupal configuration. There creates a default
# configuration to bundled with the sourcecode which is used and customised for the
# particular deployment each time.
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
####################################################################################
####################################################################################
#set -x

while ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
do
    /bin/sleep 10
done

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "1" ] && [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
then
    if ( [ -f /var/www/html/sites/default/settings.php ] && [ ! -f /var/www/html/sites/default/settings.php.default ] )
    then
        /bin/mv /var/www/html/sites/default/settings.php /var/www/html/sites/default/settings.php.default
    fi
     ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/www/html/sites/default/settings.php.default drupal_settings.php
    /bin/chmod 600 ${HOME}/config/drupal_settings.php
    /bin/touch ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED
    /bin/echo "1"
fi

