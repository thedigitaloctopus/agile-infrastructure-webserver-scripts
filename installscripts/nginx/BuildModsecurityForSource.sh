#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: This will install the modsecurity webserver for source
#######################################################################################
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
########################################################################################
########################################################################################
#set -x
/usr/bin/apt-get  -o DPkg::Lock::Timeout=-1 -qq -y install bison build-essential ca-certificates curl dh-autoreconf doxygen flex gawk git iputils-ping libcurl4-gnutls-dev libexpat1-dev libgeoip-dev liblmdb-dev libpcre3-dev libpcre++-dev libssl-dev libtool libxml2 libxml2-dev libyajl-dev locales lua5.3-dev pkg-config wget zlib1g-dev zlibc libgd-dev libxslt-dev
/usr/bin/apt-get install  -o DPkg::Lock::Timeout=-1 -y -qq libcurl4-openssl-dev
/usr/bin/apt-get install  -o DPkg::Lock::Timeout=-1 -y -qq libxml2-dev
/usr/bin/apt-get install  -o DPkg::Lock::Timeout=-1 -y -qq libpcre3-dev

cd /opt

/usr/bin/git clone https://github.com/SpiderLabs/ModSecurity

cd ModSecurity

/usr/bin/git submodule init
/usr/bin/git submodule update

./build.sh

./configure

/usr/bin/make

/usr/bin/make install

cd /opt

/usr/bin/git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

version="`/usr/sbin/nginx -v 2>&1 >/dev/null | /usr/bin/awk -F'/' '{print $NF}' | /usr/bin/awk '{print $1}'`" 

/usr/bin/wget http://nginx.org/download/nginx-${version}.tar.gz

/usr/bin/tar -xvzmf nginx-${version}.tar.gz

cd nginx-${version}

configure_arguments="`/usr/sbin/nginx -V 2>&1 >/dev/null  | /bin/grep "configure arguments:" | /usr/bin/tr '\n' ' ' | /bin/awk '{$1="";$2="";print $0}' | /bin/sed 's/\-\-add\-dynamic.*//g'`"

./configure --with-pcre=../${pcre_latest_version} --with-maxmind=no

if ( [ -d /etc/nginx/modules ] )
then
    /bin/rm -r /etc/nginx/modules
fi

/usr/bin/make modules

/bin/mkdir /etc/nginx/modules

/bin/cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules

/bin/echo "load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;" >> /etc/nginx/nginx.conf

/bin/rm -rf /usr/share/modsecurity-crs

/usr/bin/git clone https://github.com/coreruleset/coreruleset /usr/local/modsecurity-crs

/bin/mv /usr/local/modsecurity-crs/crs-setup.conf.example /usr/local/modsecurity-crs/crs-setup.conf

/bin/mv /usr/local/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/local/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf

/bin/rm /usr/local/modsecurity-crs/rules/REQUEST-910-IP-REPUTATION.conf

/bin/mkdir -p /etc/modsecurity

/bin/cp /opt/ModSecurity/unicode.mapping /etc/modsecurity

/bin/cp /opt/ModSecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

/bin/sed -i 's/SecRuleEngine.*/SecRuleEngine On/g' /etc/modsecurity/modsecurity.conf

/bin/mkdir -p /etc/nginx/modsec

/bin/echo "Include /etc/modsecurity/modsecurity.conf
Include /usr/local/modsecurity-crs/crs-setup.conf
Include /usr/local/modsecurity-crs/rules/*.conf" > /etc/nginx/modsec/main.conf
