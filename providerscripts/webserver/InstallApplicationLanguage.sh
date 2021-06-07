#!/bin/sh
###################################################################################
# Description: This will install the selected application language
# Date: 18/11/2016
# Author: Peter Winter
###################################################################################
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
###################################################################################
###################################################################################
#set -x

APPLICATION_LANGUAGE="$1"

if ( [ "${APPLICATION_LANGUAGE}" = "PHP" ] )
then
    BUILDOS="`/bin/ls ${HOME}/.ssh/BUILDOS:* | /usr/bin/awk -F':' '{print $NF}'`"
    BUILDOSVERSION="`/bin/ls ${HOME}/.ssh/BUILDOSVERSION:* | /usr/bin/awk -F':' '{print $NF}'`"

    if ( [ "${BUILDOS}" = "ubuntu" ] )
    then
        ${HOME}/installscripts/InstallPHPBase.sh ${BUILDOS}
elif ( [ "${BUILDOS}" = "debian" ] )
    then
        if ( [ "${BUILDOSVERSION}" = "9" ] )
        then
            /bin/echo "deb http://packages.dotdeb.org stretch all
            deb-src http://packages.dotdeb.org stretch all" >> /etc/apt/sources.list
        fi
        /usr/bin/wget https://www.dotdeb.org/dotdeb.gpg
        /usr/bin/apt-key add dotdeb.gpg
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        ${HOME}/installscripts/InstallPHPBase.sh ${BUILDOS}
    fi
    /bin/echo "${0} `/bin/date`: Adjusting php config" >> ${HOME}/logs/WEBSERVER_BUILD.log


    php_version="`/usr/bin/php -v | /bin/grep "^PHP" | /usr/bin/awk '{print $2}' | /usr/bin/awk -F'.' '{print $1,$2}' | /bin/sed 's/ /\./g'`"
    php_ini="/etc/php/${php_version}/fpm/php.ini"
    www_conf="/etc/php/${php_version}/fpm/pool.d/www.conf"

    /bin/sed -i "s/^;env/env/g" ${www_conf}
    /bin/sed -i "s/^listen =.*/listen = 127.0.0.1:9000/g" ${www_conf}

    php_mode="`/bin/ls ${HOME}/.ssh/PHPMODE:* | /usr/bin/awk -F':' '{print $NF}'`"
    php_max_children="`/bin/ls ${HOME}/.ssh/PHPMAXCHILDREN:* | /usr/bin/awk -F':' '{print $NF}'`"
    php_start_servers="`/bin/ls ${HOME}/.ssh/PHPSTARTSERVERS:* | /usr/bin/awk -F':' '{print $NF}'`"
    php_min_spare_servers="`/bin/ls ${HOME}/.ssh/PHPMINSPARESERVERS:* | /usr/bin/awk -F':' '{print $NF}'`"
    php_max_spare_servers="`/bin/ls ${HOME}/.ssh/PHPMAXSPARESERVERS:* | /usr/bin/awk -F':' '{print $NF}'`"
    php_process_idle_timeout="`/bin/ls ${HOME}/.ssh/PHPPROCESSIDLETIMEOUT:* | /usr/bin/awk -F':' '{print $NF}'`"

    if ( [ "${php_mode}" != "" ] )
    then
        /bin/sed -i "s/^pm =.*/pm = ${php_mode}/" ${www_conf}
        /bin/sed -i "s/^pm=.*/pm = ${php_mode}/" ${www_conf}
    else 
        /bin/sed -i "s/^pm =.*/pm = ondemand/" ${www_conf}
        /bin/sed -i "s/^pm=.*/pm = ondemand/" ${www_conf}
    fi

    if ( [ "${php_max_children}" != "" ] )
    then
        /bin/sed -i "s/^pm\.max_children.*/pm\.max_children = ${php_max_children}/" ${www_conf}
    else
        /bin/sed -i "s/^pm\.max_children.*/pm\.max_children = 80/" ${www_conf}   
        /bin/sed -i "s/^pm\.max_requests.*/pm\.max_requests = 200/" ${www_conf} 
    fi

    if ( [ "${php_start_servers}" != "" ] )
    then
        /bin/sed -i "s/^pm\.start_servers.*/pm\.start_servers = ${php_start_servers}/" ${www_conf}        
    fi

    if ( [ "${php_min_spare_servers}" != "" ] )
    then
        /bin/sed -i "s/^pm\.min_spare_servers.*/pm\.min_spare_servers = ${php_min_spare_servers}/" ${www_conf}
    fi

    if ( [ "${php_max_spare_servers}" != "" ] )
    then
        /bin/sed -i "s/^pm\.max_spare_servers.*/pm\.max_spare_servers = ${php_max_spare_servers}/" ${www_conf}
    fi

    if ( [ "${php_process_idle_timeout}" != "" ] )
    then
        /bin/sed -i "s/^pm\.process_idle_timeout.*/pm\.process_idle_timeout = ${php_process_idle_timeout}/" ${www_conf}
    else
        /bin/sed -i "s/^pm\.process_idle_timeout.*/pm\.process_idle_timeout = 10s/" ${www_conf}
    fi

    #Fiddle with the php config
    /bin/sed -i "/upload_max_filesize/c\ upload_max_filesize = 40M" ${php_ini}
    /bin/sed -i "/post_max_size/c\ post_max_size = 40M" ${php_ini}
    /bin/sed -i "/zlib.output_compression /c\ zlib.output_compression = On" ${php_ini}
    /bin/sed -i "/cgi.fix_pathinfo/c\ cgi.fix_pathinfo=0" ${php_ini}
    /bin/sed -i "/upload_tmp_dir/c\ upload_tmp_dir = /var/www/html/tmp" ${php_ini}
    /bin/sed -i "/output_buffering/c\ output_buffering = Off" ${php_ini}
    /bin/sed -i "/realpath_cache_size/c\ realpath_cache_size = 10000k" ${php_ini}
    /bin/sed -i "/max_input_vars/c\ max_input_vars = 5000" ${php_ini}
    /bin/sed -i "/max_execution_time/c\ max_execution_time = 300" ${php_ini}
    /bin/sed -i "/max_input_time/c\ max_input_time = 300" ${php_ini}
    /bin/sed -i "/default_socket_timeout/c\ default_socket_timeout = 300" ${php_ini}

    PHP_SERVICE="`/usr/sbin/service --status-all | /bin/grep php | /usr/bin/awk '{print $NF}'`"

    /usr/sbin/service ${PHP_SERVICE} restart

    if ( [ "`/bin/ps -ef | /bin/grep php | /bin/grep -v grep`" = "" ] )
    then
        /bin/echo "PHP hasn't started. Can't run without it, please investigate."
        exit
    fi
fi
