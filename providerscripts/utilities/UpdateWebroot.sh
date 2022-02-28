#!/bin/sh
#########################################################################
# Description: This will sync a webroot to the shared directory or tunnel
# Date: 16/11/2016
# Author: Peter Winter
##########################################################################
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
############################################################################
############################################################################
#set -x

#while ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
#do
#    /bin/sleep 10
#done
#/usr/bin/rsync -aruog --chown=www-data:www-data ${HOME}/config/webrootsynctunnel/var/www/html/ /var/www/html/
${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh webrootsynctunnel/var/www/html/ /var/www/html/ recursive
${HOME}/providerscripts/utilities/EnforcePermissions.sh
