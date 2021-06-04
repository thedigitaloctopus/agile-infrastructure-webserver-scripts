/usr/bin/apt install -qq -y software-properties-common
/usr/bin/apt install -qq -y build-essential 
/usr/bin/apt install -qq -y curl
/usr/bin/apt install -qq -y libapr1-dev libaprutil1-dev libpcre3-dev  

apache_latest_version="`/usr/bin/wget -q -O - https://httpd.apache.org/download.cgi | /bin/grep latest | /bin/egrep -o '[0-9]+\.[0-9]+\.[0-9]+' | /usr/bin/uniq`"

pcre_latest_version="`/usr/bin/curl 'https://ftp.pcre.org/pub/pcre/' | /bin/egrep -o 'pcre-[0-9]+\.[0-9]+' | /bin/sed 's/pcre-//g' | /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"

/usr/bin/wget https://apache.mirrors.nublue.co.uk//httpd/httpd-${apache_latest_version}.tar.gz
/usr/bin/wget https://ftp.pcre.org/pub/pcre/pcre-${pcre_latest_version}.tar.gz && /bin/tar zxvf pcre-${pcre_latest_version}.tar.gz

/bin/gzip -d httpd-${apache_latest_version}.tar.gz

/bin/tar xvf httpd-${apache_latest_version}.tar

export CFLAGS=-O2
cd pcre-${pcre_latest_version}

./configure --prefix=/usr/local/pcre
make
sudo make install

cd ../httpd-${apache_latest_version}

./configure --prefix=/usr/local/apache2 --enable-mods-shared=all --with-included-apr --with-pcre=/usr/local/pcre
make
make install

/bin/echo "#!/bin/sh
case \"\$1\" in
start)
echo \"Starting Apache ...\"
# Change the location to your specific location
/usr/local/apache2/bin/apachectl start
;;
stop)
echo \"Stopping Apache ...\"
# Change the location to your specific location
/usr/local/apache2/bin/apachectl stop
;;
graceful)
echo \"Restarting Apache gracefully...\"
# Change the location to your specific location
/usr/local/apache2/bin/apachectl graceful
;;
restart)
echo \"Restarting Apache ...\"
# Change the location to your specific location
/usr/local/apache2/bin/apachectl restart
;;
*)
echo \"Usage: '\$0' {start|stop|restart|graceful}\" 
exit 64
;;
esac
exit 0" > /etc/init.d/apache2

/bin/chmod u+x /etc/init.d/apache2

/usr/sbin/update-rc.d apache2 defaults
