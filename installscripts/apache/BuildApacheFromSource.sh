set -x

/usr/bin/apt-get -qq -y  install libnghttp2-dev libssl-dev libpcre3  build-essential autoconf libtool libexpat-dev openssl apache2-dev
cd /usr/local/src

pcre_latest_version="`/usr/bin/curl 'https://ftp.pcre.org/pub/pcre/' | /bin/egrep -o 'pcre-[0-9]+\.[0-9]+' | /bin/sed 's/pcre-//g' | /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"

/usr/bin/wget -O- https://ftp.pcre.org/pub/pcre/pcre-${pcre_latest_version}.tar.gz | /bin/tar -zxf -

cd /usr/local/src/pcre*

./configure --prefix=/usr/local/pcre 
/usr/bin/make
/usr/bin/make install

cd /usr/local/src

/usr/bin/git clone https://github.com/libexpat/libexpat.git

cd /usr/local/src/libexpat/expat

./configure --prefix=/usr/local/expat
/usr/bin/make 
/usr/bin/make install

cd /usr/local/src

apr_latest_version="`/usr/bin/curl http://apr.apache.org/download.cgi | /bin/grep "apr1" | /bin/sed 's/.*APR //g' | /usr/bin/awk '{print $1}'`"
apr_download_link="https://mirrors.ukfast.co.uk/sites/ftp.apache.org/apr/apr-${apr_latest_version}.tar.gz"

/usr/bin/wget -O- ${apr_download_link} | /bin/tar -zxf -

#apr_util_download_link="`/usr/bin/curl http://apr.apache.org/download.cgi | /bin/grep 'apr-util' | /bin/grep 'tar.gz\"' | /bin/sed 's/.*https/https/g' | /bin/sed 's/".*//g' | /bin/sed '/^$/d'`"

#/usr/bin/wget -O- ${apr_util_download_link} | /bin/tar -zxf -


cd `/bin/ls -d /usr/local/src/apr-[0-9]*.[0.9]*`

./configure --prefix=`/bin/ls -d /usr/local/src/apr-[0-9]*.[0.9]*`
/usr/bin/make
/usr/bin/make install

apache_download_link="`/usr/bin/curl http://httpd.apache.org/download.cgi | /bin/grep "Source" | /bin/grep "tar.gz" | /bin/sed 's/.*https/https/g' | /bin/sed 's/".*//g'`"

/usr/bin/wget -O- ${apache_download_link} | /bin/tar -zxf -


/bin/mkdir /usr/local/src/`/bin/ls /usr/local/src/ | /bin/grep httpd`/srclib/apr-util
/bin/mv /usr/local/src/apr-util-*/* `/bin/ls /usr/local/src/ | /bin/grep httpd`/srclib/apr-util

/bin/mkdir /usr/local/src/`/bin/ls /usr/local/src/ | /bin/grep httpd`/srclib/apr
/bin/mv /usr/local/src/apr-*/* `/bin/ls /usr/local/src/ | /bin/grep httpd`/srclib/apr

cd httpd-*

#./configure --enable-ssl --enable-so --with-mpm=event --with-included-apr --prefix=/usr/local/apache2 --with-pcre=/usr/local/pcre --enable-mods-shared="reallyall" --enable-mpms-shared="all"
#./configure --enable-ssl --enable-so --with-mpm=event --with-included-apr --enable-proxy --enable-ssl --enable-rewrite --with-mpm=worker --prefix=/usr/local/apache2 --with-pcre=/usr/local/pcre --enable-mpms-shared="all" --enable-mods-shared="all ssl cache proxy http2 authn_alias mem_cache file_cache charset_lite dav_lock disk_cache"
#./configure --prefix=/etc/apache2 --with-pcre=/usr/local/pcre --with-apxs2=/usr/bin/apxs --with-mpm=prefork --enable-http2 --enable-ssl --enable-so --with-included-apr --enable-rewrite --enable-mods-static="reallyall" --enable-mods-shared="reallyall"
/bin/mkdir /usr/local/apache2
/bin/mkdir /etc/apache2
/bin/mkdir /etc/apache2/conf
/bin/mkdir /etc/apache2/mods-available
/bin/mkdir /etc/apache2/conf-available
/bin/mkdir /etc/apache2/sites-available

###################################################################
#git clone https://github.com/apache/httpd.git
#./buildconf --with-apr=../apr-1.7.0 --with-apr-util=../apr-util-1.6

#####################################


./configure --prefix=/usr/local/apache2 --sysconfdir=/etc/apache2 --with-pcre=/usr/local/pcre --with-apr=`/bin/ls -d /usr/local/src/apr-[0-9]*.[0.9]*` -with-apxs2=/usr/bin/apxs --with-mpm=prefork --enable-http2 --enable-ssl --enable-so --with-included-apr --enable-rewrite --enable-mods-static="reallyall" --enable-mods-shared="reallyall"

/usr/bin/make

/usr/bin/make install

###INSTALL MOD SECURITY
/usr/bin/git clone https://github.com/ssdeep-project/ssdeep
cd ssdeep/
./bootstrap
./configure
/usr/bin/make
/usr/bin/make install
cd ..
/usr/bin/git clone https://github.com/SpiderLabs/ModSecurity 
cd ModSecurity 
/usr/bin/git checkout -b v3/master origin/v3/master 
/usr/bin/git submodule init 
/usr/bin/git submodule update 
/bin/sh build.sh 
./configure 
/usr/bin/make
/usr/bin/make install
cd ..
/bin/sh build.sh 
./configure 
/usr/bin/make
/usr/bin/make install
/usr/bin/git clone https://github.com/SpiderLabs/ModSecurity-apache
cd ModSecurity-apache
./autogen.sh
./configure --with-libmodsecurity=/usr/local/modsecurity
/usr/bin/make
/usr/bin/make install
cd ..
/usr/bin/wget https://github.com/SpiderLabs/owasp-modsecurity-crs/tarball/master
/bin/mv master master.tar.gz
/bin/tar xvfz master.tar.gz
/bin/cp -R SpiderLabs-owasp-modsecurity-crs-*/ /usr/local/apache2/conf/crs/
cd /usr/local/apache2/conf/crs/
/bin/mv modsecurity_crs_10_setup.conf.example modsecurity_crs_10_setup.conf
/bin/ln -s /usr/local/apache2/conf/crs/modsecurity_crs_10_setup.conf activated_rules/
for f in `ls base_rules/` ; do ln -s /usr/local/apache2/conf/crs/base_rules/$f activated_rules/$f ; done
for f in `ls optional_rules/` ; do ln -s /usr/local/apache2/conf/crs/optional_rules/$f activated_rules/$f ; done
/bin/mkdir /etc/modsec
cd
/bin/cp modsecurity-*/modsecurity.conf-recommended /etc/modsec/modsecurity.conf
/bin/cp modsecurity-*/unicode.mapping /etc/modsec/
/bin/sed -i "s/DetectionOnly/On/g" /etc/modsec/modsecurity.conf

/bin/echo "#!/bin/bash
/bin/mkdir /var/run/apache2
/bin/chown www-data.www-data /var/run/apache2

. /etc/apache2/conf/envvars && /usr/local/apache2/bin/apachectl -k start

/bin/sleep 10

apaches=\"\`/usr/bin/ps -ef | /bin/grep apache2 | /bin/grep -v grep | /usr/bin/wc -l\`\"

while ( [ \"\${apaches}\" = \"0\" ] )
do
    . /etc/apache2/conf/envvars && /usr/local/apache2/bin/apachectl -k start
    apaches=\"\`/usr/bin/ps -ef | /bin/grep apache2 | /bin/grep -v grep | /usr/bin/wc -l\`\"
    /bin/sleep 10
done

exit 0" > /etc/rc.local

/bin/chmod +x /etc/rc.local

/bin/echo "[Unit]
Description=/etc/rc.local Compatibility
Documentation=man:systemd-rc-local-generator(8)
ConditionFileIsExecutable=/etc/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/rc-local.service

/bin/cp ${HOME}/installscripts/apache/httpd.conf.sample /etc/apache2/httpd.conf
/bin/cp ${HOME}/installscripts/apache/envvars.sample /etc/apache2/envvars
/bin/cp ${HOME}/installscripts/apache/magic.sample /etc/apache2/magic
/bin/cp ${HOME}/installscripts/apache/ports.conf.sample /etc/apache2/ports.conf

/bin/mkdir /etc/apache2/sites-enabled
/bin/mkdir /etc/apache2/mods-enabled
/bin/mkdir /etc/apache2/conf-enabled

/bin/mkdir /var/log/apache2
/bin/chown www-data.www-data /var/log/apache2

#/bin/mv /etc/apache2/conf/httpd.conf /etc/apache2/conf/httpd.conf.orig
#/bin/ln -s /etc/apache2/apache2.conf /etc/apache2/conf/httpd.conf

#/bin/mv /etc/apache2/httpd.conf /etc/apache2/httpd.conf.orig
#/bin/mv /etc/apache2/apache2.conf /etc/apache2/httpd.conf
/bin/sed -i "s/^#ServerRoot.*/ServerRoot \"\/etc\/apache2\"/g" /etc/apache2/httpd.conf

/bin/mv /etc/apache2/conf/magic.conf /etc/apache2/conf/magic.orig
/bin/ln -s /etc/apache2/magic /etc/apache2/conf/magic
/bin/mv /etc/apache2/conf/envvars /etc/apache2/conf/envvars.orig
/bin/ln -s /etc/apache2/envvars /etc/apache2/conf/envvars
/bin/mv /etc/apache2/conf/ports.conf /etc/apache2/conf/ports.conf.orig
/bin/ln -s /etc/apache2/ports.conf /etc/apache2/conf/ports.conf

/bin/ln -s /etc/apache2/conf-available/remoteip.conf /etc/apache2/conf-enabled/remoteip.conf

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
then
   /bin/echo "ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/var/www/html/\$1" >> /etc/apache2/httpd.conf
   # /bin/echo "ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/var/www/html/\$1" >> /etc/apache2/httpd.conf
fi

    
/usr/bin/systemctl enable rc-local.service
/usr/bin/systemctl start rc-local.service &
