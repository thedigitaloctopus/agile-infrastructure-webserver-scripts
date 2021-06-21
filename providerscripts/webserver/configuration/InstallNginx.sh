#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will perform a base installation of Nginx. You are welcome
# to modify it to your needs.
#####################################################################################
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
##################################################################################
##################################################################################
#set -x

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
BUILDOS_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOSVERSION'`"
APPLICATION_LANGUAGE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"

${HOME}/installscripts/InstallNGINX.sh ${BUILDOS}

/bin/echo "${0} `/bin/date`: Installing NGINX" >> ${HOME}/logs/MonitoringLog.dat

#copy onto the machine our standard nginx config files
/bin/mkdir /etc/nginx/cache 2>/dev/null
/bin/rm /etc/nginx/sites-available/${website_name}
/usr/bin/unlink /etc/nginx/sites-enabled/${website_name}
/usr/bin/unlink /etc/nginx/sites-enabled/default

/bin/echo "map \$http_user_agent \$blockedagent {
default         0;
~*malicious     1;
~*bot           1;
~*backdoor      1;
~*crawler       1;
~*bandit        1;
}" >  /etc/nginx/blockuseragents.rules

/bin/echo "user www-data;
worker_processes auto;
worker_rlimit_nofile 100000;
pid /var/run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;


events {
            use epoll;
            worker_connections 2048;
            multi_accept on;
        }

        http { " > /etc/nginx/nginx.conf
        
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DNSCHOICE:cloudflare`" = "1" ] )
then
     /bin/echo "include /etc/nginx/cloudflare;" >> /etc/nginx/nginx.conf
fi

/bin/echo "
                ##
                # Basic Settings
                ##

                sendfile on;
                tcp_nopush on;
                tcp_nodelay on;

                client_body_buffer_size  10k;
                client_header_buffer_size 2k;
                client_max_body_size 30m;
                large_client_header_buffers 4 16k;
                fastcgi_buffers 32 32k;
                fastcgi_buffer_size 64k;

                types_hash_max_size 2048;
                client_body_timeout 12;
                client_header_timeout 12;
                keepalive_timeout 15;
                keepalive_requests 200;
                reset_timedout_connection on;
                send_timeout 10;
                server_tokens off;
                server_names_hash_bucket_size 64;
                server_name_in_redirect off;

                open_file_cache          max=10000 inactive=30s;
                open_file_cache_valid    60s;
                open_file_cache_min_uses 2;
                open_file_cache_errors   on;

                limit_conn_zone \$binary_remote_addr zone=addr:5m;
                limit_req_zone \$request_uri zone=zone2:10m rate=10r/m;

                include /etc/nginx/mime.types;
                default_type application/octet-stream;

        ##
        # Logging Settings
        ##

                access_log off;#/var/log/nginx/access.log;
                error_log /var/log/nginx/error.log;

        ##
        # Gzip Settings
        ##

         #       gzip on;
         #       gzip_disable "msie6";
         #       gzip_vary on;
         #       gzip_comp_level  9;
         #       gzip_min_length  256;
         #       gzip_proxied     expired no-cache no-store private auth;
         #       gzip_buffers 16 8k;
         #       gzip_http_version 1.1;
         #       gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

                ##
                # Virtual Host Configs
                ##

                include /etc/nginx/conf.d/*.conf;
                include /etc/nginx/sites-enabled/*;
}" >> /etc/nginx/nginx.conf

/bin/mkdir /etc/nginx/sites-available 2>/dev/null

/bin/echo "include /etc/nginx/blockuseragents.rules;

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name ${website_url};
    return 301 https://\$host\$request_uri;
}

server
{
    if (\$blockedagent){
        return 403;
    }

    listen 443 ssl http2 default deferred;
               #listen 443 ssl;
    ssl_certificate ${HOME}/ssl/live/${website_url}/fullchain.pem;
    ssl_certificate_key ${HOME}/ssl/live/${website_url}/privkey.pem;
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 5m;
    ssl_prefer_server_ciphers on; " > /etc/nginx/sites-available/${website_name}
    
if ( ( [ "${BUILDOS}" = "ubuntu" ] && [ "${BUILDOS_VERSION}" = "18.04" ] ) || ( [ "${BUILDOS}" = "debian" ] && [ "${BUILDOS_VERSION}" = "9" ] ) )
then
    /bin/echo "    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;" >> /etc/nginx/sites-available/${website_name}
else
    /bin/echo "    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;" >> /etc/nginx/sites-available/${website_name}
fi

/bin/echo "    
    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_stapling on;
    ssl_trusted_certificate ${HOME}/ssl/live/${website_url}/fullchain.pem;
    server_tokens off;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection \"1; mode=block\";
    
    server_name ${website_url};
    root /var/www/html;
    index index.php index.html index.htm index.pl index.py;

    if (\$request_method !~ ^(GET|HEAD|POST)$) {
        return 444;
    }

    location = /favicon.ico {
                              log_not_found off;
                              access_log off;
                            }
    location = /robots.txt {
                              deny all;
                              log_not_found off;
                              access_log off;
                           }
    if (\$http_user_agent ~* (Baiduspider|Jullo) ) {
        return 405;
    }

    # deny running scripts inside writable directories
    location ~* /(images|cache|media|logs|tmp)/.*\.(php|pl|py|jsp|asp|sh|cgi)\$ {
        return 403;
    }
    
    location ~ ^/\.user\.ini {
        deny all;
    }

    location ~ ^/wordpress/\.user\.ini {
        deny all;
    }

    # Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|swf|xml|txt|ico|pdf|flv)\$ {
        add_header Pragma \"public\";
        expires 1w;
        add_header Cache-Control \"public\";
        access_log  off;
        log_not_found off;
}" >> /etc/nginx/sites-available/${website_name}

/bin/echo "
   location / {
        allow all;
        etag off;
        add_header Pragma "public";
        expires 1w;
        add_header Cache-Control "public";
        try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
        ################################################################################################
        #Uncomment these two lines to require basic authentication before accessing your application.
        #This is a strong security measure, but, it means your authorised users will have to input
        #Their credentials twice. If you are using cloudflare, for example, you might want to use their
        #system to do the same thing, but, if you are not on cloudflare, you might want to consider this.
        #################################################################################################
        #auth_basic "Private Property";
        #auth_basic_user_file /etc/nginx/.htpasswd;
} " >> /etc/nginx/sites-available/${website_name}

${HOME}/providerscripts/dns/TrustRemoteProxy.sh

${HOME}/providerscripts/email/SendEmail.sh "THE NGINX WEBSERVER HAS BEEN INSTALLED" "Nginx webserver is installed and primed"
