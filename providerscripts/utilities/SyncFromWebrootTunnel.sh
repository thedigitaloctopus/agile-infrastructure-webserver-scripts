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

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
    exit
fi

#if ( [ -f ${HOME}/config/ENABLESYNCTUNNEL ] )
#then
#    /bin/touch ${HOME}/config/SYNCTUNNELENABLED
#    /bin/rm ${HOME}/config/ENABLESYNCTUNNEL
#    /bin/rm -r ${HOME}/config/webrootsynctunnel/*
#fi

#if ( [ ! -f ${HOME}/config/SYNCTUNNELENABLED ] )
#then
#    exit
#fi

######IS THIS NEEDED???????????
#if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webrootsynctunnel/UPDATED*`" != "" ] )
#then
#    /bin/umount ${HOME}/config
#    ${HOME}/providerscripts/datastore/SetupConfig.sh
#fi

ip="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"

#if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
#then
#    exit
#fi

if ( [ ! -d ${HOME}/webrootsync/incomingupdates ] )
then
    /bin/mkdir -p ${HOME}/webrootsync/incomingupdates
fi

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh webrootsynctunnel/webrootsync*.tar ${HOME}/webrootsync/incomingupdates
#/bin/cp ${HOME}/config/webrootsynctunnel/webrootsync*.tar ${HOME}/webrootsync/incomingupdates 2>/dev/null
/bin/rm ${HOME}/webrootsync/incomingupdates/*${ip}* 2>/dev/null

cd /var/www/html

updated=0

if ( [ "`/bin/ls -l ${HOME}/webrootsync/incomingupdates/webrootsync*.tar | /usr/bin/wc -l`" -gt "0" ] )
then
    if ( [ -f ${HOME}/runtime/FIRST_TUNNEL_SYNC ] )
    then
        /bin/cat ${HOME}/webrootsync/incomingupdates/webrootsync*.tar | /bin/tar -xf - -i 2>/dev/null
        /bin/rm ${HOME}/runtime/FIRST_TUNNEL_SYNC
        updated=1
    else
        /bin/cat ${HOME}/webrootsync/incomingupdates/webrootsync*.tar | /bin/tar -xf - --keep-newer-files -i 2>/dev/null
        /bin/rm ${HOME}/webrootsync/incomingupdates/webrootsync*.tar 2>/dev/null
        updated=1
    fi
fi
if ( [ "${updated}" = "1" ] )
then
    /usr/bin/find /var/www/html -type d -print | /usr/bin/xargs chown www-data.www-data
    /usr/bin/find /var/www/html -type f -print | /usr/bin/xargs chown www-data.www-data
    /usr/bin/find /var/www/html -type d -print | /usr/bin/xargs chmod 755
    /usr/bin/find /var/www/html -type f -print | /usr/bin/xargs chmod 664
fi
