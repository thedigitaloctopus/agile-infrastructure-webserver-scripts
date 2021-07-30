apache_download_link="`/usr/bin/curl http://httpd.apache.org/download.cgi | /bin/grep "Source" | /bin/grep "tar.gz" | /bin/sed 's/.*https/https/g' | /bin/sed 's/".*//g'`"
apache_version="`/bin/echo ${apache_download_link} | /bin/sed 's/.*\///g' | sed 's/.tar.gz//g'`"
/usr/bin/wget -O- ${apache_download_link} | /bin/tar -zxf -

cd /usr/local/src/${apache_vesion}/srclib/
wget https://downloads.apache.org/apr/apr-1.7.0.tar.gz
tar -xzf apr-1.7.0.tar.gz
mv apr-1.7.0 apr


wget https://downloads.apache.org/apr/apr-util-1.6.1.tar.gz
tar -xzf apr-util-1.6.1.tar.gz
mv apr-util-1.6.1 apr-util

pcre_latest_version="`/usr/bin/curl 'https://ftp.pcre.org/pub/pcre/' | /bin/egrep -o 'pcre-[0-9]+\.[0-9]+' | /bin/sed 's/pcre-//g' | /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"

/usr/bin/wget -O- https://ftp.pcre.org/pub/pcre/pcre-${pcre_latest_version}.tar.gz | /bin/tar -zxf -

cd /usr/local/src/${apache_version}

./configure --prefix=/usr/local/apache2 --sysconfdir=/etc/apache2  --with-mpm=prefork --enable-http2 --enable-ssl --enable-so --enable-rewrite --enable-mods-static="reallyall" --enable-mods-shared="reallyall"

make
make install
