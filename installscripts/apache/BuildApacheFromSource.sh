#!/bin/sh
######################################################################################################
# Description: This script will install the apache webserver from source
# The advantages of installing from source is that you can use the latest available version of the software
# the apt repositories tend to be quite some way behind the newest releases.
# Also, you have more control over what modules are used. You can add and remove modules as you need to 
# by changing the configuration parameters
# The disadvantage is that the build process will take longer to complete
# Author: Peter Winter
# Date: 04/06/2021
#######################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

#Install needed libraries
/usr/bin/apt-get -qq -y  install libnghttp2-dev  build-essential automake autoconf libtool software-properties-common libtool-bin libgeoip-dev

cd /usr/local/src

#Download and build PCRE
pcre_latest_version="`/usr/bin/curl 'https://ftp.pcre.org/pub/pcre/' | /bin/egrep -o 'pcre-[0-9]+\.[0-9]+' | /bin/sed 's/pcre-//g' | /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"
/usr/bin/wget -O- https://ftp.pcre.org/pub/pcre/pcre-${pcre_latest_version}.tar.gz | /bin/tar -zxf -
#openssl_latest_version="`/usr/bin/wget -q -O - https://www.openssl.org/source | grep openssl-1. | /bin/sed 's/.*openssl-//g' | /bin/sed 's/.tar.*//g'`"
#/usr/bin/wget https://www.openssl.org/source/openssl-${openssl_latest_version}.tar.gz && tar xzvf openssl-${openssl_latest_version}.tar.gz

cd /usr/local/src/pcre*

./configure --prefix=/usr/local/pcre 
/usr/bin/make
/usr/bin/make install

cd /usr/local/src

#Download and build libexpat
/usr/bin/git clone https://github.com/libexpat/libexpat.git

cd /usr/local/src/libexpat/expat
./buildconf.sh
./configure --prefix=/usr/local/expat
/usr/bin/make 
/usr/bin/make install

cd /usr/local/src

#Download and build apache
apache_download_link="`/usr/bin/curl http://httpd.apache.org/download.cgi | /bin/grep "Source" | /bin/grep "tar.gz" | /bin/sed 's/.*https/https/g' | /bin/sed 's/".*//g'`"
/usr/bin/wget -O- ${apache_download_link} | /bin/tar -zxf -

#Download about build apr
apr_latest_version="`/usr/bin/curl http://apr.apache.org/download.cgi | /bin/grep "apr1" | /bin/sed 's/.*APR //g' | /usr/bin/awk '{print $1}'`"
apr_download_link="https://mirrors.ukfast.co.uk/sites/ftp.apache.org/apr/apr-${apr_latest_version}.tar.gz"

/usr/bin/wget -O- ${apr_download_link} | /bin/tar -zxf - -C httpd-*/srclib

cd /usr/local/src/httpd-*/srclib
/bin/ln -s apr-${apr_latest_version}/ apr

cd /usr/local/src

#Download and build apr-util
apr_util_download_link="`/usr/bin/curl http://apr.apache.org/download.cgi | /bin/grep 'apr-util' | /bin/grep 'tar.gz\"' | /bin/sed 's/.*https/https/g' | /bin/sed 's/".*//g' | /bin/sed '/^$/d'`"
/usr/bin/wget -O- ${apr_util_download_link} | /bin/tar -zxf - -C httpd-*/srclib

cd /usr/local/src/httpd-*/srclib
/bin/ln -s apr-util* apr-util

/bin/mkdir /usr/local/apache2
/bin/mkdir /etc/apache2
/bin/mkdir /etc/apache2/conf
/bin/mkdir /etc/apache2/mods-available
/bin/mkdir /etc/apache2/conf-available
/bin/mkdir /etc/apache2/sites-available

cd /usr/local/src/httpd-*
    
options=" --prefix=/usr/local/apache2 --sysconfdir=/etc/apache2 --enable-ssl --enable-so --enable-http2 --enable-rewrite --enable-mods-shared=\"reallyall\" --with-mpm=worker --with-included-apr --with-apxs2=/usr/local/apache2/bin/apxs --with-pcre=/usr/local/pcre --with-expat=/usr/local/expat/ "

./buildconf 

./configure ${options}

/usr/bin/make

/usr/bin/make install

cd ..

if ( [ "${2}" = "modsecurity" ] )
then
    #Download and build and configure mod security
    dir="`/usr/bin/pwd`"
    /usr/bin/git clone https://github.com/ssdeep-project/ssdeep
    cd ssdeep/
    ./bootstrap
    ./configure
    /usr/bin/make
    /usr/bin/make install
    cd ${dir}
    
    /usr/bin/git clone https://github.com/SpiderLabs/ModSecurity 
    cd ModSecurity 
    /usr/bin/git checkout -b v3/master origin/v3/master 
    /usr/bin/git submodule init 
    /usr/bin/git submodule update 
    /bin/sh build.sh 
    ./configure  -with-maxmind=no
    /usr/bin/make
    /usr/bin/make install
    cd ${dir}
    /usr/bin/git clone https://github.com/SpiderLabs/ModSecurity-apache
    cd ModSecurity-apache
    ./autogen.sh
    ./configure --with-libmodsecurity=/usr/local/modsecurity 
    /usr/bin/make
    /usr/bin/make install
    cd ${dir}

    /usr/sbin/ldconfig

    #Install modsecurity rules
    /usr/bin/git clone https://github.com/SpiderLabs/ModSecurity 
    /bin/mkdir /etc/apache2/modsecurity.d 
    /bin/cp ./ModSecurity/modsecurity.conf-recommended /etc/apache2/modsecurity.d/modsecurity.conf 
    /bin/cp ./ModSecurity/modsec_rules.conf /etc/apache2/modsecurity.d/modsec_rules.conf
    /bin/cp ./ModSecurity/unicode.mapping /etc/apache2/modsecurity.d/ 
    /bin/sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/apache2/modsecurity.d/modsecurity.conf
    /usr/bin/git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /etc/apache2/modsecurity.d/owasp-crs 
    /bin/cp /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf.example /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf
    cd /etc/apache2/modsecurity.d
  
    /bin/echo "Include \"/etc/apache2/modsecurity.d/modsecurity.conf\"" > modsec_rules.conf
    /bin/echo "Include \"/etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf\"" >> modsec_rules.conf
    /bin/echo "Include \"/etc/apache2/modsecurity.d/owasp-crs/rules/*.conf\"" >> modsec_rules.conf

    cd ${dir}


    WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
    /bin/sed -i '/:443/a modsecurity on\nmodsecurity_rules_file /etc/apache2/modsecurity.d/modsec_rules.conf' /etc/apache2/sites-available/${WEBSITE_NAME}
fi

if ( [ "${3}" = "modevasive" ] )
then                      
    export DEBIAN_FRONTEND=noninteractive 
    /usr/bin/apt-get -qq -y install apache2-utils
    /usr/bin/apt-get -qq -y install libapache2-mod-evasive
            
    /bin/mkdir /var/log/mod_evasive 
    /bin/chown -R www-data:www-data /var/log/mod_evasive
            
    cd ..
            
    if ( [ -f /etc/apache2/mods-available/evasive.conf ] )
    then 
        /bin/rm /etc/apache2/mods-available/evasive.conf
    fi
    /bin/mkdir /etc/apache2/mods-available
    /bin/mkdir /etc/apache2/mods-enabled
            
    /bin/cp ${HOME}/installscripts/apache/mod_evasive.sample /etc/apache2/mods-available/evasive.conf
    /usr/bin/ln -s /etc/apache2/mods-available/evasive.conf /etc/apache2/mods-enabled/evasive.conf
    notify_email_address="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SYSTEMTOEMAILADDRESS'`"
            
    if ( [ "${notify_email_address}" != "" ] )
    then
        /bin/sed -i "s/DOSEmailNotify.*/DOSEmailNotify ${notify_email_address}/g" /etc/apache2/mods-available/evasive.conf
    fi
fi
/bin/cp /usr/local/apache2/conf/mime.types /etc/apache2/conf

#Install configuration values for apache
/bin/cp ${HOME}/installscripts/apache/httpd.conf.sample /etc/apache2/httpd.conf
/bin/cp ${HOME}/installscripts/apache/envvars.sample /etc/apache2/envvars
/bin/cp ${HOME}/installscripts/apache/magic.sample /etc/apache2/magic
/bin/cp ${HOME}/installscripts/apache/ports.conf.sample /etc/apache2/ports.conf

/bin/mkdir /etc/apache2/sites-enabled
/bin/mkdir /etc/apache2/mods-enabled
/bin/mkdir /etc/apache2/conf-enabled

/bin/mkdir /var/log/apache2
/bin/chown www-data.www-data /var/log/apache2

#Set required modules for loading
/bin/echo "LoadModule unixd_module  /usr/local/apache2/modules/mod_unixd.so
LoadModule authz_core_module  /usr/local/apache2/modules/mod_authz_core.so
LoadModule alias_module  /usr/local/apache2/modules/mod_alias.so
LoadModule log_config_module /usr/local/apache2/modules/mod_log_config.so
LoadModule log_debug_module /usr/local/apache2/modules/mod_log_debug.so
LoadModule logio_module /usr/local/apache2/modules/mod_logio.so
LoadModule remoteip_module /usr/local/apache2/modules/mod_remoteip.so
LoadModule expires_module /usr/local/apache2/modules/mod_expires.so
LoadModule access_compat_module /usr/local/apache2/modules/mod_access_compat.so
LoadModule dir_module /usr/local/apache2/modules/mod_dir.so
LoadModule proxy_module /usr/local/apache2/modules/mod_proxy.so
LoadModule proxy_http_module /usr/local/apache2/modules/mod_proxy_http.so
LoadModule proxy_fcgi_module /usr/local/apache2/modules/mod_proxy_fcgi.so
LoadModule headers_module /usr/local/apache2/modules/mod_headers.so
LoadModule rewrite_module /usr/local/apache2/modules/mod_rewrite.so
LoadModule ssl_module /usr/local/apache2/modules/mod_ssl.so
LoadModule mime_module /usr/local/apache2/modules/mod_mime.so
LoadModule unique_id_module /usr/local/apache2/modules/mod_unique_id.so
LoadModule session_module /usr/local/apache2/modules/mod_session.so
LoadModule session_cookie_module /usr/local/apache2/modules/mod_session_cookie.so
LoadModule http2_module /usr/local/apache2/modules/mod_http2.so
LoadModule authn_core_module /usr/local/apache2/modules/mod_authn_core.so
LoadModule authz_user_module /usr/local/apache2/modules/mod_authz_user.so
LoadModule authn_file_module /usr/local/apache2/modules/mod_authn_file.so
LoadModule auth_basic_module /usr/local/apache2/modules/mod_auth_basic.so" > /etc/apache2/httpd.conf.$$
  
if ( [ "${2}" = "modsecurity" ] )
then
    /bin/echo "LoadModule security3_module /usr/local/apache2/modules/mod_security3.so" >> /etc/apache2/httpd.conf.$$
# LoadModule maxminddb_module /usr/local/apache2/modules/mod_maxminddb.so" >> /etc/apache2/httpd.conf.$$
fi

if ( [ "${3}" = "modevasive" ] )
then
    /bin/echo "LoadModule evasive20_module /usr/lib/apache2/modules/mod_evasive20.so" >> /etc/apache2/httpd.conf.$$
fi

/bin/cat /etc/apache2/httpd.conf >> /etc/apache2/httpd.conf.$$
/bin/mv /etc/apache2/httpd.conf.$$ /etc/apache2/httpd.conf
/bin/sed -i "s/^#ServerRoot.*/ServerRoot \"\/etc\/apache2\"/g" /etc/apache2/httpd.conf

/bin/mv /etc/apache2/conf/magic.conf /etc/apache2/conf/magic.orig
/bin/ln -s /etc/apache2/magic /etc/apache2/conf/magic
/bin/mv /etc/apache2/conf/envvars /etc/apache2/conf/envvars.orig
/bin/ln -s /etc/apache2/envvars /etc/apache2/conf/envvars
/bin/mv /etc/apache2/conf/ports.conf /etc/apache2/conf/ports.conf.orig
/bin/ln -s /etc/apache2/ports.conf /etc/apache2/conf/ports.conf

/bin/ln -s /etc/apache2/conf-available/*php*.conf /etc/apache2/conf-enabled/php.conf

#Setup to pass PHP requests to FCGI
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
then
   /bin/echo "ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/var/www/html/\$1" >> /etc/apache2/httpd.conf
fi

/bin/cp ${HOME}/installscripts/apache/init.d.sample /etc/init.d/apache2
/usr/sbin/update-rc.d apache2
/usr/bin/systemctl enable apache2.service
/usr/bin/systemctl start apache2.service &


