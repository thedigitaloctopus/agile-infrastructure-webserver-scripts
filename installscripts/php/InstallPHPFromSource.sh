/usr/bin/apt-get -qq -y install build-essential autoconf re2c bison libpq-dev libonig-dev libfcgi-dev libfcgi0ldbl libjpeg-dev libpng-dev libssl-dev libxml2-dev libcurl4-openssl-dev libxpm-dev libgd-dev libmysqlclient-dev libfreetype6-dev libxslt1-dev libpspell-dev libzip-dev libsqlite3-dev
cd /opt

/usr/bin/git clone https://github.com/php/php-src.git

cd php-src

./buildconf

./configure --prefix=/opt/php/php8 --enable-cli --enable-fpm --enable-intl --enable-mbstring --enable-opcache --enable-sockets --enable-soap --with-curl --with-freetype --with-fpm-user=www-data --with-fpm-group=www-data --with-jpeg --with-mysql-sock --with-mysqli --with-openssl --with-pdo-mysql --with-pgsql --with-xsl --with-zlib


/usr/bin/make

/usr/bin/make install

/bin/cp /opt/php-src/php.ini-production /opt/php/php8/lib/php.ini

/bin/sed -i 's/;zend_extension/zend_extension/g' /opt/php/php8/lib/php.ini

/bin/sed -i 's/;opcache/opcache/g' /opt/php/php8/lib/php.ini

/bin/echo "pid = run/php-fpm.pid
[www]
user = www-data
group = www-data
listen = 127.0.0.1:8999
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 2
pm.max_spare_servers = 4" >> /opt/php/php8/etc/php-fpm.conf


/bin/echo "#! /bin/sh
### BEGIN INIT INFO
# Provides:          php-8-fpm
# Required-Start:    \$all
# Required-Stop:     \$all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts php-8-fpm
# Description:       starts the PHP FastCGI Process Manager daemon
### END INIT INFO
php_fpm_BIN=/opt/php/php8/sbin/php-fpm
php_fpm_CONF=/opt/php/php8/etc/php-fpm.conf
php_fpm_PID=/opt/php/php8/var/run/php-fpm.pid
php_opts=\"--fpm-config $php_fpm_CONF\"

wait_for_pid () {
        try=0
        while test \$try -lt 35 ; do
                case \"\$1\" in
                        'created')
                        if [ -f \"\$2\" ] ; then
                                try=''
                                break
                        fi
                        ;;
                        'removed')
                        if [ ! -f \"\$2\" ] ; then
                                try=''
                                break
                        fi
                        ;;
                esac
                echo -n .
                try=`expr \$try + 1`
                sleep 1
        done
}
case \"\$1\" in
        start)
                echo -n \"Starting php-fpm \"
                \$php_fpm_BIN \$php_opts
                if [ \"\$?\" != 0 ] ; then
                        echo \" failed\"
                        exit 1
                fi
                wait_for_pid created \$php_fpm_PID
                if [ -n \"\$try\" ] ; then
                        echo \" failed\"
                        exit 1
                else
                        echo \" done\"
                fi
        ;;
        stop)
                echo -n \"Gracefully shutting down php-fpm \"
                if [ ! -r \$php_fpm_PID ] ; then
                        echo \"warning, no pid file found - php-fpm is not running ?\"
                        exit 1
                fi
                kill -QUIT `cat \$php_fpm_PID`
                wait_for_pid removed \$php_fpm_PID
                if [ -n \"\$try\" ] ; then
                        echo \" failed. Use force-exit\"
                        exit 1
                else
                        echo \" done\"
                       echo \" done\"
                fi
        ;;
        force-quit)
                echo -n \"Terminating php-fpm \"
                if [ ! -r \$php_fpm_PID ] ; then
                        echo \"warning, no pid file found - php-fpm is not running ?\"
                        exit 1
                fi
                kill -TERM `cat \$php_fpm_PID`
                wait_for_pid removed \$php_fpm_PID
                if [ -n \"\$try\" ] ; then
                        echo \" failed\"
                        exit 1
                else
                        echo \" done\"
                fi
        ;;
        restart)
                \$0 stop
                \$0 start
        ;;
        reload)
                echo -n \"Reload service php-fpm \"
                if [ ! -r \$php_fpm_PID ] ; then
                        echo \"warning, no pid file found - php-fpm is not running ?\"
                        exit 1
                fi
                kill -USR2 `cat \$php_fpm_PID`
                echo \" done\"
        ;;
        *)
                echo \"Usage: \$0 {start|stop|force-quit|restart|reload}\"
                exit 1
        ;;
esac
" > /etc/init.d/php-8-fpm

/bin/chmod 755 /etc/init.d/php-8-fpm

/usr/sbin/update-rc.d php-8-fpm defaults
