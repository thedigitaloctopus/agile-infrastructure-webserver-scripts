#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will customise the nginx configuration on an application
# by application basis. If you application has any specific settings it needs, then
# this is the place to put them.
####################################################################################
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
#################################################################################
#################################################################################
#set -x



WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
         /bin/echo "location ~* /moodle/admin {
      
      set \$auth_basic off;
      
      if (-f /etc/basicauth/.htpasswd) {
         set \$auth_basic \"Private Property\";
      }

      auth_basic \$auth_basic;
      auth_basic_user_file /etc/basicauth/.htpasswd;
}" >> /etc/nginx/sites-available/${website_name}
    fi

    /bin/echo "
    location = / {
        rewrite ^ https://${WEBSITE_URL}/moodle redirect;
    }    

    rewrite ^(.*\.php)(/)(.*)\$ \$1?file=/\$3 last;

    location ~ [^/]\.php(/|\$) {
        fastcgi_split_path_info  ^(.+\.php)(/.+)\$;
        fastcgi_buffers 8 16k;
        fastcgi_buffer_size 32k;
        fastcgi_index index.php;
     #   fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_pass 127.0.0.1:9000;
        include fastcgi_params;
        fastcgi_read_timeout 90;
        fastcgi_send_timeout 90;
        fastcgi_connect_timeout 90;
        fastcgi_keep_conn on;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }    
    "  >> /etc/nginx/sites-available/${website_name}
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
         /bin/echo "location ~* / {
      
      set \$auth_basic off;
      
      if (-f /etc/basicauth/.htpasswd) {
         set \$auth_basic \"Private Property\";
      }

      auth_basic \$auth_basic;
      auth_basic_user_file /etc/basicauth/.htpasswd;
}" >> /etc/nginx/sites-available/${website_name}
    fi

    /bin/echo "    location ~ '\.php$|^/update.php' {
        fastcgi_split_path_info ^(.+?\.php)(|/.*)$;
        include fastcgi_params;
        fastcgi_param HTTP_PROXY \"\";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_param QUERY_STRING \$query_string;
        fastcgi_intercept_errors on;
        # PHP 7 socket location.
        #fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_pass 127.0.0.1:9000;
    }
    "  >> /etc/nginx/sites-available/${website_name}
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
         /bin/echo "location ~* /wp-admin {
      
      set \$auth_basic off;
      
      if (-f /etc/basicauth/.htpasswd) {
         set \$auth_basic \"Private Property\";
      }

      auth_basic \$auth_basic;
      auth_basic_user_file /etc/basicauth/.htpasswd;
}" >> /etc/nginx/sites-available/${website_name}
    fi
    
    /bin/echo "location /wp-content/uploads/bp-attachments/ {
    rewrite ^.*uploads/bp-attachments/([0-9]+)/(.*) /?p=\$1&bp-attachment=\$2 permanent;
}" >> /etc/nginx/sites-available/${website_name}

    /bin/echo "location ^~ /uploads/ {
}" >> /etc/nginx/sites-available/${website_name}

   /bin/echo "
    location ~ \.php\$ {
        allow all;
        try_files \$uri =404;
        fastcgi_buffers 8 16k;
        fastcgi_buffer_size 32k;
        include /etc/nginx/fastcgi_params;
        fastcgi_read_timeout 90;
        fastcgi_send_timeout 90;
        fastcgi_connect_timeout 90;
        fastcgi_keep_conn on;
        #fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
    " >> /etc/nginx/sites-available/${website_name}
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
         /bin/echo "location ~* /administrator {
      
      set \$auth_basic off;
      
      if (-f /etc/basicauth/.htpasswd) {
         set \$auth_basic \"Private Property\";
      }

      auth_basic \$auth_basic;
      auth_basic_user_file /etc/basicauth/.htpasswd;
}" >> /etc/nginx/sites-available/${website_name}
    fi
    
    /bin/echo "
    location ~ \.php\$ {
        allow all;
        try_files \$uri =404;
        fastcgi_buffers 8 16k;
        fastcgi_buffer_size 32k;
        include /etc/nginx/fastcgi_params;
        fastcgi_read_timeout 90;
        fastcgi_send_timeout 90;
        fastcgi_connect_timeout 90;
        fastcgi_keep_conn on;
        #fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
    " >> /etc/nginx/sites-available/${website_name}
fi

/bin/echo "}" >> /etc/nginx/sites-available/${website_name}

