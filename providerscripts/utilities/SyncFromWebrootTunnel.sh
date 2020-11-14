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

if ( [ ! -f ${HOME}/runtime/INSTALLEDSUCCESSFULLY ] )
then
    exit
fi

ip="`/bin/ls ${HOME}/.ssh/MYPUBLICIP:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
then
    exit
fi

if ( [ ! -d ${HOME}/webrootsync/incomingupdates ] )
then
    /bin/mkdir -p ${HOME}/webrootsync/incomingupdates
fi

/bin/cp ${HOME}/config/webrootsynctunnel/webrootsync*.tar ${HOME}/webrootsync/incomingupdates
/bin/rm ${HOME}/webrootsync/incomingupdates/*${ip}* > /dev/null
cd /var/www/html
/bin/cat ${HOME}/webrootsync/incomingupdates/webrootsync*.tar | /bin/tar -xf - --keep-newer-files -i
/bin/rm ${HOME}/webrootsync/incomingupdates/webrootsync*.tar
