#!/bin/sh
##################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will customise Apache on an application by application
# basis. If you application has any specific settings that it needs configured, then,
# this is the place to set them.
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
####################################################################################
####################################################################################
#set -x

WEBSITE_NAME="`/bin/ls ${HOME}/.ssh/WEBSITEDISPLAYNAME:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ -f ${HOME}/.ssh/APPLICATION:drupal ] )
then
    /bin/sed -i 's/<\/VirtualHost>//g' /etc/apache2/sites-available/${WEBSITE_NAME}
    /bin/echo "<Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    RewriteEngine on
    RewriteBase /
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} !=/favicon.ico
    RewriteRule ^ index.php [L]
    </Directory>
    </VirtualHost>" >> /etc/apache2/sites-available/${WEBSITE_NAME}

fi

if ( [ -f ${HOME}/.ssh/APPLICATION:joomla ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/joomla-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
fi

if ( [ -f ${HOME}/.ssh/APPLICATION:wordpress ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/wordpress-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
fi
