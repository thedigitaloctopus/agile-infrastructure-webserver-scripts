#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will perform a base installation of Lighttpd. You are
# welcome to modify it to your needs.
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

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
phpversion="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"

${HOME}/installscripts/InstallLighttpd.sh ${BUILDOS}
#${HOME}/installscripts/InstallPHPCGI.sh ${BUILDOS}

/bin/sed -i "/cgi.fix_pathinfo/c\ cgi.fix_pathinfo=1" /etc/php/${phpversion}/fpm/php.ini
/bin/cp /etc/lighttpd/conf-available/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf.bak

/bin/echo "fastcgi.server += ( \".php\" =>
        ((
                \"host\" => \"127.0.0.1\",
                \"port\" => \"9000\",
                \"broken-scriptfilename\" => \"enable\"
        ))
)" > /etc/lighttpd/conf-available/15-fastcgi-php.conf

/usr/sbin/lighttpd-enable-mod fastcgi
/usr/sbin/lighttpd-enable-mod fastcgi-php

/bin/echo "\$SERVER[\"socket\"] == \":443\" {
ssl.engine = \"enable\"
ssl.pemfile = \"${HOME}/ssl/live/${website_url}/privkey.pem\"
ssl.ca-file = \"${HOME}/ssl/live/${website_url}/fullchain.pem\"
ssl.ec-curve = \"secp384r1\"
ssl.honor-cipher-order = \"enable\"
ssl.cipher-list = \"EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH\"
ssl.use-compression = \"disable\"
setenv.add-response-header = (
\"Strict-Transport-Security\" => \"max-age=63072000; includeSubdomains; preload\",
\"X-Frame-Options\" => \"DENY\",
\"X-Content-Type-Options\" => \"nosniff\"
)
ssl.use-sslv2 = \"disable\"
ssl.use-sslv3 = \"enable\"
server.name = \"${website_url}\"
accesslog.filename = \"/var/log/lighttpd/access.log\"
" >>  /etc/lighttpd/lighttpd.conf

/bin/sed -i '/server.modules/a \"mod_rewrite\",' /etc/lighttpd/lighttpd.conf
/bin/sed -i '/server.modules/a \"mod_proxy\",' /etc/lighttpd/lighttpd.conf

${HOME}/providerscripts/email/SendEmail.sh "THE LIGHTTPD WEBSERVER HAS BEEN INSTALLED" "Lighttpd webserver is installed and primed"
