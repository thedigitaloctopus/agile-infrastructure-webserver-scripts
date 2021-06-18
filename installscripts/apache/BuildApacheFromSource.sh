set -x

/usr/bin/apt -qq -y  install libnghttp2-dev libssl-dev libpcre3  build-essential autoconf libtool libexpat-dev openssl apache2-dev
cd /usr/local/src

pcre_latest_version="`/usr/bin/curl 'https://ftp.pcre.org/pub/pcre/' | /bin/egrep -o 'pcre-[0-9]+\.[0-9]+' | /bin/sed 's/pcre-//g' | /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"

/usr/bin/wget -O- https://ftp.pcre.org/pub/pcre/pcre-${pcre_latest_version}.tar.gz | /bin/tar -zxf -

cd /usr/local/src/pcre*

./configure --prefix=/usr/local/pcre 
make
make install

cd /usr/local/src

/usr/bin/git clone https://github.com/libexpat/libexpat.git

cd /usr/local/src/libexpat/expat

./configure --prefix=/usr/local/expat
make 
make install

cd /usr/local/src

apache_download_link="`/usr/bin/curl http://httpd.apache.org/download.cgi | /bin/grep "Source" | /bin/grep "tar.gz" | /bin/sed 's/.*https/https/g' | /bin/sed 's/".*//g'`"

/usr/bin/wget -O- ${apache_download_link} | /bin/tar -zxf -

apr_latest_version="`/usr/bin/curl http://apr.apache.org/download.cgi | /bin/grep "apr1" | /bin/sed 's/.*APR //g' | /usr/bin/awk '{print $1}'`"
apr_download_link="https://mirrors.ukfast.co.uk/sites/ftp.apache.org/apr/apr-${apr_latest_version}.tar.gz"

/usr/bin/wget -O- ${apr_download_link} | /bin/tar -zxf -

apr_util_download_link="`/usr/bin/curl http://apr.apache.org/download.cgi | /bin/grep 'apr-util' | /bin/grep 'tar.gz\"' | /bin/sed 's/.*https/https/g' | /bin/sed 's/".*//g' | /bin/sed '/^$/d'`"

/usr/bin/wget -O- ${apr_util_download_link} | /bin/tar -zxf -

/bin/mkdir /usr/local/src/`/bin/ls /usr/local/src/ | /bin/grep httpd`/srclib/apr-util
/bin/mv /usr/local/src/apr-util-*/* `/bin/ls /usr/local/src/ | /bin/grep httpd`/srclib/apr-util

/bin/mkdir /usr/local/src/`/bin/ls /usr/local/src/ | /bin/grep httpd`/srclib/apr
/bin/mv /usr/local/src/apr-*/* `/bin/ls /usr/local/src/ | /bin/grep httpd`/srclib/apr

cd httpd-*

#./configure --enable-ssl --enable-so --with-mpm=event --with-included-apr --prefix=/usr/local/apache2 --with-pcre=/usr/local/pcre --enable-mods-shared="reallyall" --enable-mpms-shared="all"
#./configure --enable-ssl --enable-so --with-mpm=event --with-included-apr --enable-proxy --enable-ssl --enable-rewrite --with-mpm=worker --prefix=/usr/local/apache2 --with-pcre=/usr/local/pcre --enable-mpms-shared="all" --enable-mods-shared="all ssl cache proxy http2 authn_alias mem_cache file_cache charset_lite dav_lock disk_cache"
./configure prefix=/usr/local/apache2 --with-pcre=/usr/local/pcre --with-apxs2=/usr/bin/apxs --enable-http2 --enable-ssl --enable-so --enable-mpms-shared='prefork event' --with-included-apr --enable-rewrite -- --enable-mods-static="reallyall" --enable-mods-shared="reallyall"

make

make install

/bin/echo "#!/bin/bash
/bin/mkdir /var/run/apache2
/bin/chown www-data.www-data /var/run/apache2
/usr/local/apache2/bin/apachectl -k start
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

/bin/cp ${HOME}/installscripts/apache/apache2.conf.sample /etc/apache2/apache2.conf
/bin/cp ${HOME}/installscripts/apache/envvars.sample /etc/apache2/envvars
/bin/cp ${HOME}/installscripts/apache/magic.sample /etc/apache2/magic
/bin/cp ${HOME}/installscripts/apache/ports.conf.sample /etc/apache2/ports.conf

/bin/mkdir /etc/apache2/sites-enabled
/bin/mkdir /etc/apache2/mods-enabled
/bin/mkdir /etc/apache2/conf-enabled

/bin/mkdir /var/log/apache2
/bin/chown www-data.www-data /var/log/apache2

/usr/bin/systemctl enable rc-local.service
/usr/bin/systemctl start rc-local.service
