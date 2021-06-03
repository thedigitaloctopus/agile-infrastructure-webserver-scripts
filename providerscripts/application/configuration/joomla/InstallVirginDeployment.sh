#!/bin/sh
#####################################################################################
# Description: This script will install a virgin copy of joomla
# Author: Peter Winter
# Date: 04/01/2017
######################################################################################
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
######################################################################################
######################################################################################
#set -x

version="`/bin/echo ${APPLICATION} | /usr/bin/awk -F':' '{print $NF}'`"
cd /var/www/html

# temporary hack for alpha releases, remove when stable is released alpha4.0.0-alpha12
if ( [ "`/bin/echo ${version} | /bin/grep alpha`" != "" ] )
then
    /usr/bin/wget https://github.com/joomla/joomla-cms/releases/download/${version}/Joomla_${version}-Alpha-Full_Package.zip
	/usr/bin/unzip Joomla_${version}-Alpha-Full_Package.zip
    /bin/rm Joomla_${version}-Alpha-Full_Package.zip
    /bin/mv /var/www/html/htaccess.txt /var/www/html/.htaccess
    /bin/chown -R www-data.www-data /var/www/html/*
    cd /home/${SERVER_USER}
    /bin/echo "1"
elif ( [ "`/bin/echo ${version} | /bin/grep beta`" != "" ] )
then
    /usr/bin/wget https://github.com/joomla/joomla-cms/releases/download/${version}/Joomla_${version}-Beta-Full_Package.zip
    /usr/bin/unzip Joomla_${version}-Beta-Full_Package.zip
    /bin/rm Joomla_${version}-Beta-Full_Package.zip
    /bin/mv /var/www/html/htaccess.txt /var/www/html/.htaccess
    /bin/chown -R www-data.www-data /var/www/html/*
    cd /home/${SERVER_USER}
    /bin/echo "1"
elif ( [ "`/bin/echo ${version} | /bin/grep release_candidate`" != "" ] )
then
    /usr/bin/wget https://github.com/joomla/joomla-cms/releases/download/${version}/Joomla_${version}-Release_Candidate-Full_Package.zip
    /usr/bin/unzip Joomla_${version}-Release_Candidate-Full_Package.zip
    /bin/rm Joomla_${version}-Release_Candidate-Full_Package.zip
    /bin/mv /var/www/html/htaccess.txt /var/www/html/.htaccess
    /bin/chown -R www-data.www-data /var/www/html/*
    cd /home/${SERVER_USER}
    /bin/echo "1"

else
    /usr/bin/wget https://github.com/joomla/joomla-cms/releases/download/${version}/Joomla_${version}-Stable-Full_Package.zip
    /usr/bin/unzip Joomla_${version}-Stable-Full_Package.zip
    /bin/rm Joomla_${version}-Stable-Full_Package.zip
    /bin/mv /var/www/html/htaccess.txt /var/www/html/.htaccess
    /bin/chown -R www-data.www-data /var/www/html/*
    cd /home/${SERVER_USER}
    /bin/echo "1"
fi
