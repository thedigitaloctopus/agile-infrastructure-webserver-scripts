#!/bin/sh
###################################################################################
# Description: This script will install a virgin copy of drupal
# Author: Peter Winter
# Date: 04/01/2017
##################################################################################
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


version="`/bin/echo ${APPLICATION} | /usr/bin/awk -F':' '{print $NF}'`"

cd /var/www/html

if ( [ "`/bin/echo ${APPLICATION} | /bin/grep 'social'`" = "" ] )
then
    product="drupal"
else
    product="social"
fi

if ( [ "${product}" = "drupal" ] )
then
    cd /var/www/html
    /usr/bin/wget https://ftp.drupal.org/files/projects/${product}-${version}.tar.gz
    /bin/tar xvfx ${product}-${version}.tar.gz
    /bin/rm ${product}-${version}.tar.gz
    /bin/mv ${product}-${version}/* .
    /bin/mv ${product}-${version}/.* .
    /bin/rmdir ${product}-${version}
    /bin/rm -r .git
    /bin/chown -R www-data.www-data /var/www/html/*
    cd /home/${SERVER_USER}
    /bin/echo "1"
elif ( [ "${product}" = "social" ] )
then
    #So, this is here, it doesn't work, it requires php7.4 (not 8), if you can get it to work, I'd like that
    #You can look up more about it its called opensocial and is a drupal application
    BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
    ${HOME}/installscripts/InstallComposer.sh ${BUILDOS}
    #/usr/local/bin/composer create-project goalgorilla/social_template:dev-master DIR --no-interaction --ignore-platform-reqs
    /usr/bin/wget https://raw.githubusercontent.com/goalgorilla/social_template/master/composer.json
    /usr/bin/wget https://raw.githubusercontent.com/goalgorilla/social_template/master/composer.lock
    /bin/mv composer* ${HOME}
    cd ${HOME}
    SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"    
    /usr/sbin/runuser -l ${SERVER_USER}  -c 'composer install'
    /bin/rm /var/www/html/*
    /bin/mv vendor /var/www
    /bin/mv html/* /var/www/html
    /bin/chown -R www-data.www-data /var/www/html/*
    cd ${HOME}
    /bin/echo "1"
fi
