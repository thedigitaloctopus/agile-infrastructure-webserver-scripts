/usr/bin/apt install -qq -y software-properties-common
/usr/bin/apt install -qq -y build-essential 

nginx_latest_version="`/usr/bin/curl 'http://nginx.org/download/' |   /bin/egrep -o 'nginx-[0-9]+\.[0-9]+\.[0-9]+' | /bin/sed 's/nginx-//g' |  /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"

pcre_latest_version="`/usr/bin/curl 'https://ftp.pcre.org/pub/pcre/' | /bin/egrep -o 'pcre-[0-9]+\.[0-9]+' | /bin/sed 's/pcre-//g' | /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"

zlib_latest_version="`/usr/bin/curl 'https://www.zlib.net' | /bin/egrep -o 'zlib-[0-9]+\.[0-9]+\.[0-9]+' | /bin/sed 's/zlib-//g' | /usr/bin/sort --version-sort | /usr/bin/uniq | /usr/bin/tail -1`"

openssl_latest_version="`/usr/bin/wget -q -O - https://www.openssl.org/source | grep openssl-1. | /bin/sed 's/.*openssl-//g' | /bin/sed 's/.tar.*//g'`"

perl_version="`/usr/bin/perl -v | /bin/egrep -o 'v[0-9]+\.[0-9]+\.[0-9]+' | /bin/sed 's/v//g'`"

/usr/bin/wget https://nginx.org/download/nginx-${nginx_latest_version}.tar.gz && /bin/tar zxvf nginx-${nginx_latest_version}.tar.gz
/usr/bin/wget https://ftp.pcre.org/pub/pcre/pcre-${pcre_latest_version}.tar.gz && /bin/tar zxvf pcre-${pcre_latest_version}.tar.gz
/usr/bin/wget https://www.zlib.net/zlib-${zlib_latest_version}.tar.gz && /bin/tar zxvf zlib-${zlib_latest_version}.tar.gz
/usr/bin/wget https://www.openssl.org/source/openssl-${openssl_latest_version}.tar.gz && tar xzvf openssl-${openssl_latest_version}.tar.gz

/bin/rm *.tar.gz*

/usr/bin/apt install -qq -y perl libperl-dev libgd3 libgd-dev libgeoip1 libgeoip-dev geoip-bin libxml2 libxml2-dev libxslt1.1 libxslt1-dev

/bin/cp ~/nginx-${nginx_latest_version}/man/nginx.8 /usr/share/man/man8
/bin/gzip /usr/share/man/man8/nginx.8

cd nginx*

./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=nginx \
            --group=nginx \
            --build=Ubuntu \
            --builddir=nginx-${nginx_latest_version} \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_stub_status_module \
            --with-http_perl_module=dynamic \
            --with-perl_modules_path=/usr/share/perl/${perl_version} \
            --with-perl=/usr/bin/perl \
            --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-mail=dynamic \
            --with-mail_ssl_module \
            --with-stream=dynamic \
            --with-stream_ssl_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-stream_ssl_preread_module \
            --with-compat \
            --with-pcre=../pcre-${pcre_latest_version} \
            --with-pcre-jit \
            --with-zlib=../zlib-${zlib_latest_version} \
            --with-openssl=../openssl-${openssl_latest_version}\
            --with-openssl-opt=no-nextprotoneg \
            --with-debug

/usr/bin/make
/usr/bin/make install

cd ..

/bin/ln -s /usr/lib/nginx/modules /etc/nginx/modules

/usr/sbin/adduser --system --home /nonexistent --shell /bin/false --no-create-home --disabled-login --disabled-password --gecos "nginx user" --group nginx

/bin/mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/prox:wy_temp /var/cache/nginx/scgi_temp /var/cache/nginx/uwsgi_temp
/bin/chmod 700 /var/cache/nginx/*
/bin/chown www-data:www-data /var/cache/nginx/*

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
/usr/bin/systemctl start nginx.service

/bin/rm /etc/nginx/*.default
/bin/mkdir /etc/nginx/conf.d
/bin/mkdir /etc/nginx/snippets
/bin/mkdir /etc/nginx/sites-available
/bin/mkdir /etc/nginx/sites-enabled
/bin/mkdir /etc/nginx/modules-available
/bin/mkdir /etc/nginx/modules-enabled

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

/bin/echo "
# Self signed certificates generated by the ssl-cert package
# Don't use them in a production server!

ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;" > /etc/nginx/snippets/snakeoil.conf

/bin/rm -rf nginx-* openssl-* pcre* zlib-*
