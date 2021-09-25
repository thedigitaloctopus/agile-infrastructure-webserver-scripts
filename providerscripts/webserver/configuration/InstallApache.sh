#!/bin/sh
#################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will provide a base installation of Apache. You are
# welcome to modify it to your needs.
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

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

${HOME}/installscripts/InstallApache.sh ${BUILDOS}

if ( [ ! -d /etc/apache2/mods-available ] )
then
    /bin/mkdir /etc/apache2/mods-available
fi

if ( [ ! -d /etc/apache2/conf-available ] )
then
    /bin/mkdir /etc/apache2/conf-available
fi

if ( [ ! -d /etc/apache2/sites-available ] )
then
    /bin/mkdir /etc/apache2/sites-available
fi

/bin/echo "
TimeOut 45 
LimitRequestFields 50 
ServerTokens Prod

NameVirtualHost *:80
<VirtualHost *:80>
   ServerName ${website_url}
   DocumentRoot /var/www/html
   Redirect permanent / https://${website_url}
</VirtualHost>

<VirtualHost _default_:443>
        ServerAdmin webmaster@${website_url}
        ServerName ${website_url}
        ServerAlias ${website_url}
        DocumentRoot /var/www/html
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
        ServerSignature Off
        FileETag none
        Options -Includes
        Options -ExecCGI
        Options -FollowSymLinks
        LimitRequestFieldSize 16380
        ExpiresActive On
        Protocols h2 
        SSLEngine on
        SSLProtocol         -all +TLSv1.2 +TLSv1.3
        SSLCipherSuite      ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
        SSLHonorCipherOrder on
        SSLCompression      off
        SSLSessionTickets   off
        SSLCertificateFile ${HOME}/ssl/live/${website_url}/fullchain.pem
        SSLCertificateKeyFile ${HOME}/ssl/live/${website_url}/privkey.pem
        
       # ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/var/www/html/\$1

        <FilesMatch \"\.(cgi|shtml|phtml|php)\$\">
                        SSLOptions +StdEnvVars
        </FilesMatch>
        <IfModule mod_expires.c>
            ExpiresActive \"on\"
            ExpiresDefault \"access plus 2 days\"
            ExpiresByType text/html \"access plus 8 days\"
            ExpiresByType image/gif \"access plus 8 days\"
            ExpiresByType image/jpg \"access plus 8 days\"
            ExpiresByType image/jpeg \"access plus 8 days\"
            ExpiresByType image/png \"access plus 8 days\"
            ExpiresByType text/js \"access plus 8 days\"
            ExpiresByType text/javascript \"access plus 8 days\"
            ExpiresByType text/css \"access plus 8 days\"
</IfModule>" > /etc/apache2/sites-available/${WEBSITE_NAME}

if ( [ -f /usr/local/apache2/modules/mod_security3.so ] )
then
    /bin/echo "modsecurity on" >> /etc/apache2/sites-available/${WEBSITE_NAME}
    /bin/echo "modsecurity_rules_file /etc/apache2/modsecurity.d/modsec_rules.conf" >> /etc/apache2/sites-available/${WEBSITE_NAME}
elif ( [ -f /usr/lib/apache2/modules/mod_security2.so ] )
then
    /bin/echo "SecRuleEngine On" >> /etc/apache2/sites-available/${WEBSITE_NAME}
fi

/bin/echo "
         <Directory />
            Order Deny,Allow
            Require all denied
            Options None
            AllowOverride None
        </Directory>
        <Directory /var/www/html>
                DirectoryIndex index.php
                LimitRequestBody 512000
                LimitXMLRequestBody 10485760
                AllowOverride ALL
                Options -Includes -ExecCGI -Indexes 
                Require all granted
        </Directory>
</VirtualHost>" >> /etc/apache2/sites-available/${WEBSITE_NAME}


/bin/ln -s /etc/apache2/sites-available/${WEBSITE_NAME} /etc/apache2/sites-enabled/${WEBSITE_NAME}

if ( [ -f /etc/apache2/apache2.conf ] )
then
    /bin/sed -i "s/\/var\/www\//\/var\/www\/html/g" /etc/apache2/apache2.conf
    /bin/sed -i '/sites-enabled/d' /etc/apache2/apache2.conf
    /bin/echo "IncludeOptional sites-enabled/${WEBSITE_NAME}" >> /etc/apache2/apache2.conf
fi


/bin/sed -i 's/LoadModule/#LoadModule/g' /etc/apache2/mods-available/include.load
/bin/sed -i 's/LoadModule/#LoadModule/g' /etc/apache2/mods-available/info.load
/bin/sed -i 's/LoadModule/#LoadModule/g' /etc/apache2/mods-available/userdir.load
/bin/sed -i 's/LoadModule/#LoadModule/g' /etc/apache2/mods-available/status.load

/bin/sed -i '0,/SetHandler.*/s//SetHandler "proxy:fcgi:\/\/localhost:9000"/g' /etc/apache2/conf-available/php${PHP_VERSION}-fpm.conf

/bin/rm /etc/apache2/sites-available/*def*

/usr/sbin/a2enmod proxy_fcgi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
then
    /usr/sbin/a2enconf php${PHP_VERSION}-fpm
fi

${HOME}/providerscripts/dns/TrustRemoteProxy.sh

/usr/sbin/a2enmod ssl
/usr/sbin/a2enmod rewrite
/usr/sbin/a2enmod expires
/usr/sbin/a2enmod headers
/usr/sbin/a2enmod proxy
/usr/sbin/a2enmod proxy_http
/usr/sbin/a2enmod remoteip
/usr/sbin/a2enconf remoteip

${HOME}/providerscripts/email/SendEmail.sh "THE APACHE WEBSERVER HAS BEEN INSTALLED" "Apache webserver is installed and primed"
