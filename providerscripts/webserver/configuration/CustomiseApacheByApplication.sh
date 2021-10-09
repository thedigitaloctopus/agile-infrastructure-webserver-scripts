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

WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
    #/bin/sed -i 's/<\/VirtualHost>//g' /etc/apache2/sites-available/${WEBSITE_NAME}
    /usr/bin/tac /etc/apache2/sites-available/${WEBSITE_NAME} | /bin/sed '0,/<\/VirtualHost>/{/<\/VirtualHost>/d;}' | /usr/bin/tac > /etc/apache2/sites-available/${WEBSITE_NAME}.$$
    /bin/mv /etc/apache2/sites-available/${WEBSITE_NAME}.$$ /etc/apache2/sites-available/${WEBSITE_NAME}
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
    Redirect permanent /index.php/user/login https://${website_url}/user/login
    </Directory>
    </VirtualHost>" >> /etc/apache2/sites-available/${WEBSITE_NAME}
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
        /usr/bin/tac /etc/apache2/sites-available/${WEBSITE_NAME} | /bin/sed '0,/<\/VirtualHost>/{/<\/VirtualHost>/d;}' | /usr/bin/tac > /etc/apache2/sites-available/${WEBSITE_NAME}.$$
        /bin/mv /etc/apache2/sites-available/${WEBSITE_NAME}.$$ /etc/apache2/sites-available/${WEBSITE_NAME}
        /bin/echo "    <Directory /var/www/html/>
                AuthType Basic
                AuthName \"Private Property\"
                AuthUserFile /etc/basicauth/.htpasswd
                Require valid-user 
                ####BYPASS####
        </Directory>
    </VirtualHost>" >> /etc/apache2/sites-available/${WEBSITE_NAME}
    fi

fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/joomla-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
        /usr/bin/tac /etc/apache2/sites-available/${WEBSITE_NAME} | /bin/sed '0,/<\/VirtualHost>/{/<\/VirtualHost>/d;}' | /usr/bin/tac > /etc/apache2/sites-available/${WEBSITE_NAME}.$$
        /bin/mv /etc/apache2/sites-available/${WEBSITE_NAME}.$$ /etc/apache2/sites-available/${WEBSITE_NAME}
        /bin/echo "    <Directory /var/www/html/administrator>
                AuthType Basic
                AuthName \"Private Property\"
                AuthUserFile /etc/basicauth/.htpasswd
                Require valid-user 
                ####BYPASS####
        </Directory>
    </VirtualHost>" >> /etc/apache2/sites-available/${WEBSITE_NAME}
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    /bin/cp ${HOME}/providerscripts/application/configuration/wordpress-htaccess.txt /var/www/html/.htaccess
    /bin/chown www-data.www-data /var/www/html/.htaccess
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
        /usr/bin/tac /etc/apache2/sites-available/${WEBSITE_NAME} | /bin/sed '0,/<\/VirtualHost>/{/<\/VirtualHost>/d;}' | /usr/bin/tac > /etc/apache2/sites-available/${WEBSITE_NAME}.$$
        /bin/mv /etc/apache2/sites-available/${WEBSITE_NAME}.$$ /etc/apache2/sites-available/${WEBSITE_NAME}
        /bin/echo "    <Directory /var/www/html/wp-admin>
                AuthType Basic
                AuthName \"Private Property\"
                AuthUserFile /etc/basicauth/.htpasswd
                Require valid-user 
                ####BYPASS####
        </Directory>
    </VirtualHost>" >> /etc/apache2/sites-available/${WEBSITE_NAME}
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"
    /bin/sed -i "/cgi.fix_pathinfo/c\ cgi.fix_pathinfo=1" /etc/php/${PHP_VERSION}/fpm/php.ini
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
        /usr/bin/tac /etc/apache2/sites-available/${WEBSITE_NAME} | /bin/sed '0,/<\/VirtualHost>/{/<\/VirtualHost>/d;}' | /usr/bin/tac > /etc/apache2/sites-available/${WEBSITE_NAME}.$$
        /bin/mv /etc/apache2/sites-available/${WEBSITE_NAME}.$$ /etc/apache2/sites-available/${WEBSITE_NAME}
        /bin/echo "    <Directory /var/www/html/moodle/admin>
                AuthType Basic
                AuthName \"Private Property\"
                AuthUserFile /etc/basicauth/.htpasswd
                Require valid-user 
                ####BYPASS####
        </Directory>
    </VirtualHost>" >> /etc/apache2/sites-available/${WEBSITE_NAME}
    fi
    
    /usr/bin/tac /etc/apache2/sites-available/${WEBSITE_NAME} | /bin/sed '0,/<\/VirtualHost>/{/<\/VirtualHost>/d;}' | /usr/bin/tac > /etc/apache2/sites-available/${WEBSITE_NAME}.$$
    /bin/mv /etc/apache2/sites-available/${WEBSITE_NAME}.$$ /etc/apache2/sites-available/${WEBSITE_NAME}
    /bin/echo "        <Directory "/var/www/html/moodledata">
    Require all denied
        </Directory>
    </VirtualHost>" >> /etc/apache2/sites-available/${WEBSITE_NAME}
    

fi
