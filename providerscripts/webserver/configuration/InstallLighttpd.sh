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
PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"

${HOME}/installscripts/InstallLighttpd.sh ${BUILDOS}
#${HOME}/installscripts/InstallPHPCGI.sh ${BUILDOS}

/bin/sed -i "/cgi.fix_pathinfo/c\ cgi.fix_pathinfo=1" /etc/php/${PHP_VERSION}/fpm/php.ini

if ( [ -f /etc/lighttpd/conf-available/15-fastcgi-php.conf ] )
then
     /bin/cp /etc/lighttpd/conf-available/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf.bak

    /bin/echo "fastcgi.server += ( \".php\" =>
        ((
                \"host\" => \"127.0.0.1\",
                \"port\" => \"9000\",
                \"broken-scriptfilename\" => \"enable\"
        ))
    )" > /etc/lighttpd/conf-available/15-fastcgi-php.conf
else
    /bin/echo "fastcgi.server += ( \".php\" =>
        ((
                \"host\" => \"127.0.0.1\",
                \"port\" => \"9000\",
                \"broken-scriptfilename\" => \"enable\"
        ))
    )" > /etc/lighttpd/conf.d/fastcgi.conf
fi

/usr/sbin/lighttpd-enable-mod fastcgi
/usr/sbin/lighttpd-enable-mod fastcgi-php

/bin/echo "\$SERVER[\"socket\"] == \":443\" {
ssl.engine = \"enable\"
ssl.pemfile = \"${HOME}/ssl/live/${website_url}/privkey.pem\"
ssl.ca-file = \"${HOME}/ssl/live/${website_url}/fullchain.pem\"
ssl.ec-curve = \"secp384r1\"
ssl.honor-cipher-order = \"enable\"
ssl.cipher-list = \"EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK:!SSLv3\"
ssl.disable-client-renegotiation = \"enable\"
ssl.use-compression = \"disable\"
setenv.add-response-header = (
\"Strict-Transport-Security\" => \"max-age=63072000; includeSubdomains; preload\",
\"X-Frame-Options\" => \"DENY\",
\"X-Content-Type-Options\" => \"nosniff\"
)
ssl.use-sslv2 = \"disable\"
ssl.use-sslv3 = \"disable\"
server.name = \"${website_url}\"
accesslog.filename = \"/var/log/lighttpd/access.log\"
" >>  /etc/lighttpd/lighttpd.conf

if ( [ -f /etc/lighttpd/modules.conf ] )
then
    modules_file="/etc/lighttpd/modules.conf"
else
    modules_file="/etc/lighttpd/lighttpd.conf"
fi

if ( [ "${modules_file}" = "/etc/lighttpd/lighttpd.conf" ] )
then
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_rewrite\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_proxy\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_access\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_setenv\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_auth\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_redirect\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_status\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_alias\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_userdir\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_fastcgi\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_ssi\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_compress\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_expire\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_accesslog\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_openssl\",' ${modules_file}
fi
if ( [ "${modules_file}" = "/etc/lighttpd/modules.conf" ] )
then
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_rewrite\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_proxy\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_access\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_setenv\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_auth\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_redirect\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_status\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_alias\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_userdir\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_fastcgi\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_ssi\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_compress\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_expire\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_accesslog\",' ${modules_file}
    /bin/sed -i '0,/^server.modules/!b;//a \"mod_openssl\",' ${modules_file}
    /bin/sed -i '/.*include.*rewrite.conf.*/c\include \"conf.d/rewrite.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*proxy.conf.*/c\include \"conf.d/proxy.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*access.conf.*/c\include \"conf.d/access.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*setenv.conf.*/c\include \"conf.d/setenv.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*auth.conf.*/c\include \"conf.d/auth.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*redirect.conf.*/c\include \"conf.d/redirect.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*status.conf.*/c\include \"conf.d/status.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*alias.conf.*/c\include \"conf.d/alias.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*userdir.conf.*/c\include \"conf.d/userdir.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*fastcgi.conf.*/c\include \"conf.d/fastcgi.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*ssi.conf.*/c\include \"conf.d/ssi.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*compress.conf.*/c\include \"conf.d/compress.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*expire.conf.*/c\include \"conf.d/expire.conf\"' ${modules_file}
    /bin/sed -i '/.*include.*accesslog.conf.*/c\include \"conf.d/accesslog.conf\"' ${modules_file}
fi

${HOME}/providerscripts/email/SendEmail.sh "THE LIGHTTPD WEBSERVER HAS BEEN INSTALLED" "Lighttpd webserver is installed and primed"
