#!/bin/sh
######################################################################################################
# Description: This script will install the nginx webserver from source
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
buildtype="${1}"

export HOME=`/bin/cat /home/homedir.dat`
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

#Install needed libraries
if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
then
    /usr/bin/apt-get install  -o DPkg::Lock::Timeout=-1 -qq -y software-properties-common libtool build-essential curl libmaxminddb-dev libgeoip-dev
    /usr/bin/apt-get install  -o DPkg::Lock::Timeout=-1 -y -qq libpcre3-dev
fi

#Get the latest version numbers of the software that we need
nginx_latest_version="`/usr/bin/curl 'http://nginx.org/download/' |   /bin/egrep -o 'nginx-[0-9]+\.[0-9]+\.[0-9]+' | /bin/sed 's/nginx-//g' |  /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"
#pcre_latest_version="`/usr/bin/curl https://github.com/PhilipHazel/pcre2/releases | /bin/grep pcre2[-] | /bin/grep '.tar.gz' | /usr/bin/head -1 |  /bin/sed 's/.*\///g' | /bin/sed 's/\.tar\.gz.*//g'`"
zlib_latest_version="`/usr/bin/curl 'https://www.zlib.net' | /bin/egrep -o 'zlib-[0-9]+\.[0-9]+\.[0-9]+' | /bin/sed 's/zlib-//g' | /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"
openssl_latest_version="`/usr/bin/wget -q -O - https://www.openssl.org/source | grep openssl-1. | /bin/sed 's/.*openssl-//g' | /bin/sed 's/.tar.*//g'`"
perl_version="`/usr/bin/perl -v | /bin/egrep -o 'v[0-9]+\.[0-9]+\.[0-9]+' | /bin/sed 's/v//g'`"

#Download the latest versions of the software we will be using
/usr/bin/wget https://nginx.org/download/nginx-${nginx_latest_version}.tar.gz && /bin/tar zxvf nginx-${nginx_latest_version}.tar.gz
#/usr/bin/wget -qO- https://github.com/PhilipHazel/pcre2/releases/download/${pcre_latest_version}/${pcre_latest_version}.tar.gz | /bin/tar xzf -
/usr/bin/wget https://www.zlib.net/zlib-${zlib_latest_version}.tar.gz && /bin/tar zxvf zlib-${zlib_latest_version}.tar.gz
/usr/bin/wget https://www.openssl.org/source/openssl-${openssl_latest_version}.tar.gz && tar xzvf openssl-${openssl_latest_version}.tar.gz


#Build PCRE (Perl Compatible Regular Expressions)
#cd ${pcre_latest_version}
#./configure --prefix=/usr/local/pcre 
#/usr/bin/make
#/usr/bin/make install
#cd ..

/bin/cp -r openssl-${openssl_latest_version} /usr/local/openssl


if ( [ "${2}" = "modsecurity" ] )
then
   # #Prepare and install ModSecurity
   # /usr/bin/git clone https://github.com/SpiderLabs/ModSecurity
   # cd ModSecurity
   # dir=`/usr/bin/pwd`
   # /usr/bin/git checkout v3/master
   # /usr/bin/git submodule init
   # /usr/bin/git submodule update
   # /bin/sh build.sh
   # ./configure --with-pcre=../${pcre_latest_version} --with-maxmind=no
   # /usr/bin/make
   # /usr/bin/make install
   # cd ..

   # #Prepare and install ModSecurity nginx adapter
   # /usr/bin/git clone https://github.com/SpiderLabs/ModSecurity-nginx
   #. ${HOME}/installscripts/nginx/BuildModsecurityForSource.sh
   
   #Install needed libraries
   if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
   then
      /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -y -qq bison build-essential ca-certificates curl dh-autoreconf doxygen flex gawk git iputils-ping libcurl4-gnutls-dev libexpat1-dev libgeoip-dev liblmdb-dev libpcre3-dev libpcre++-dev libssl-dev libtool libxml2 libxml2-dev libyajl-dev locales lua5.3-dev pkg-config wget zlib1g-dev zlibc libgd-dev libxslt-dev
      /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -y -qq libcurl4-openssl-dev
      /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -y -qq libxml2-dev
      /usr/bin/apt-get install -o DPkg::Lock::Timeout=-1 -y -qq libpcre3-dev
   fi
   /usr/bin/git clone https://github.com/SpiderLabs/ModSecurity
   cd ModSecurity
   /usr/bin/git submodule init
   /usr/bin/git submodule update
   ./build.sh
   ./configure
    /usr/bin/make
    /usr/bin/make install
    cd ..
    /usr/bin/git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
   
fi

/bin/rm *.tar.gz*

#Install additional libraries that we are building NGINX with
if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
then
   /usr/bin/apt-get install -qq  -o DPkg::Lock::Timeout=-1 -y perl libperl-dev libgd3 libgd-dev libxml2 libxml2-dev libxslt1.1 libxslt1-dev
fi

#Setup the manual page
/bin/cp ~/nginx-${nginx_latest_version}/man/nginx.8 /usr/share/man/man8
/bin/gzip /usr/share/man/man8/nginx.8

#download geoip2 module
/usr/bin/git clone https://github.com/leev/ngx_http_geoip2_module.git

cd nginx*

#Perform the build. You can add and remove modules from here as suits your build requirements

options=" --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --with-openssl=/usr/local/openssl --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --user=www-data --group=www-data --build=${buildtype} --builddir=nginx-${nginx_latest_version} --with-select_module --with-poll_module --with-threads --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_perl_module=dynamic --with-http_geoip_module --with-stream_geoip_module --with-perl_modules_path=/usr/share/perl/${perl_version} --with-perl=/usr/bin/perl --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-mail=dynamic --with-mail_ssl_module --with-stream=dynamic --with-stream_ssl_module --with-stream_realip_module --with-stream_ssl_preread_module --with-compat --with-pcre --with-pcre-jit --with-zlib=../zlib-${zlib_latest_version} --with-openssl-opt=no-nextprotoneg --with-debug --add-dynamic-module=../ngx_http_geoip2_module"

if ( [ "${2}" = "modsecurity" ] )
then
    options="${options} --add-dynamic-module=../ModSecurity-nginx"
fi

./configure ${options}
            
/usr/bin/make modules
#/bin/cp nginx-*/ngx_http_modsecurity_module.so /etc/nginx/modules
#/bin/cp nginx-*/ngx_http_geoip2_module.so /etc/nginx/modules
/bin/cp nginx-*/*.so /etc/nginx/modules

/usr/bin/make
/usr/bin/make install

if ( [ "${2}" = "modsecurity" ] )
then
    #Setup the rules for modsecurity
    /bin/mkdir -p /etc/nginx/modsec
    cd /etc/nginx/modsec
    /usr/bin/git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
    /bin/mv /etc/nginx/modsec/owasp-modsecurity-crs/crs-setup.conf.example /etc/nginx/modsec/owasp-modsecurity-crs/crs-setup.conf
    #/bin/rm /etc/nginx/modsec/owasp-modsecurity-crs/rules/REQUEST-910-IP-REPUTATION.conf #Requires MaxMind
    cd ${dir}
    /bin/cp modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
    /bin/cp unicode.mapping /etc/nginx/modsec

    /bin/echo "
Include /etc/nginx/modsec/owasp-modsecurity-crs/crs-setup.conf
Include /etc/nginx/modsec/owasp-modsecurity-crs/rules/*.conf" > /etc/nginx/modsec/main.conf
    /bin/sed -i 's/DetectionOnly/On/g' /etc/nginx/modsec/modsecurity.conf

    cd ..
fi

/bin/ln -s /usr/lib/nginx/modules /etc/nginx/modules

/usr/sbin/adduser --system --shell /bin/false --no-create-home --disabled-login --disabled-password --gecos "nginx user" --group nginx

/bin/mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/prox:wy_temp /var/cache/nginx/scgi_temp /var/cache/nginx/uwsgi_temp
/bin/chmod 700 /var/cache/nginx/*
/bin/chown www-data:www-data /var/cache/nginx/*

#Setup the script which will start nginx

/bin/echo "[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/nginx.service

/usr/bin/systemctl enable nginx.service

#Make sure all the necessary directories exist

/bin/rm /etc/nginx/*.default
/bin/mkdir /etc/nginx/conf.d
/bin/mkdir /etc/nginx/snippets
/bin/mkdir /etc/nginx/sites-available
/bin/mkdir /etc/nginx/sites-enabled
/bin/mkdir /etc/nginx/modules-available
/bin/mkdir /etc/nginx/modules-enabled

#Setup logging

/bin/chmod 640 /var/log/nginx/*
/bin/chown www-data www-data /var/log/nginx/access.log /var/log/nginx/error.log

/bin/echo "/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 640 nginx adm
    sharedscripts
    postrotate
            if [ -f /var/run/nginx.pid ]; then
                    kill -USR1 `cat /var/run/nginx.pid`
            fi
    endscript
}" > /etc/logrotate.d/nginx

#Setup some config files in snippets

/bin/mkdir /etc/nginx/snippets

/bin/echo "# regex to split $uri to $fastcgi_script_name and $fastcgi_path
fastcgi_split_path_info ^(.+?\.php)(/.*)$;
# Check that the PHP script exists before passing it
try_files $fastcgi_script_name =404;
# Bypass the fact that try_files resets $fastcgi_path_info
# see: http://trac.nginx.org/nginx/ticket/321
set $path_info $fastcgi_path_info;
fastcgi_param PATH_INFO $path_info;
fastcgi_index index.php;
include fastcgi.conf;" > /etc/nginx/snippets/fastcgi-php.conf

#/bin/echo "
## Self signed certificates generated by the ssl-cert package
## Don't use them in a production server!
#
#ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
#ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;" > /etc/nginx/snippets/snakeoil.conf

#Cleanup

/bin/rm -rf nginx-* openssl-* pcre* zlib-* ModSecurity* ngx_http*

#Start NGINX

/usr/bin/systemctl start nginx.service
