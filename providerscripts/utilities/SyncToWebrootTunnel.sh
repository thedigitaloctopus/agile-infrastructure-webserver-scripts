#!/bin/sh
#############################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Sync webroot updates
#############################################################################################
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
########################################################################################
########################################################################################
set -x

ip="`/bin/ls ${HOME}/.ssh/MYPUBLICIP:* | /usr/bin/awk -F':' '{print $NF}'`"

if test `/usr/bin/find ${HOME}/runtime/NEWLYBUILT -mmin -20`
then
    exit
fi


if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
then
    exit
fi

if ( [ ! -f ${HOME}/config/INSTALLEDSUCCESSFULLY ] )
then
    exit
else
    if ( [ ! -f ${HOME}/runtime/ENABLEDTOSYNC ] )
    then
        /bin/touch ${HOME}/runtime/ENABLEDTOSYNC
    fi
fi

if test `/usr/bin/find ${HOME}/runtime/ENABLEDTOSYNC -mmin -10`
then
    exit
fi

directoriestomiss="`/bin/ls ${HOME}/.ssh/DIRECTORIESTOMOUNT:* | /bin/sed 's/.*DIRECTORIESTOMOUNT://g' | /bin/sed 's/:/ /g' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

if ( [ "${directoriestomiss}" = "" ] )
then
    CMD="`/usr/bin/find /var/www/html/ -cmin -20 -mmin -20 -type f`"
else
    if ( [ -f ${HOME}/.ssh/PERSISTASSETSTOCLOUD:0 ] )
    then
        CMD="/usr/bin/find /var/www/html/ -type f -mmin -20 -cmin -20"
    else
        CMD="/usr/bin/find /var/www/html/ -type f -mmin -20 -cmin -20 -not -path "

        for directorytomiss in ${directoriestomiss}
        do
            CMD=${CMD}"'/var/www/html/${directorytomiss}/*' -not -path "
            CMD=${CMD}"'/var/www/html/${directorytomiss}' -not -path "
        done

        CMD="`/bin/echo ${CMD} | /bin/sed 's/-not -path$//g'`"
    fi
fi

eval ${CMD} > ${HOME}/runtime/newandmodfiles.dat

if ( [ ! -d ${HOME}/webrootsync ] )
then
    /bin/mkdir ${HOME}/webrootsync 
fi

if ( [ ! -d ${HOME}/config/webrootsynctunnel ] )
then
    /bin/mkdir -p ${HOME}/config/webrootsynctunnel
fi

cd /var/www/html

if ( [ -f ${HOME}/config/webrootsynctunnel/sync*purge ] )
then
    syncfile="webrootsyncXX.${ip}.tar"
else
    syncfile="webrootsync.${ip}.tar"
fi

if ( [ ! -f ${HOME}/config/webrootsynctunnel/sync*purge ] && [ -f ${HOME}/webrootsync/webrootsyncXX.${ip}.tar ] )
then
    /bin/mv ${HOME}/webrootsync/webrootsyncXX.${ip}.tar  ${HOME}/webrootsync/webrootsync.${ip}.tar  
fi

for file in `/bin/cat ${HOME}/runtime/newandmodfiles.dat`
do
    file="`/bin/echo ${file} | /bin/sed 's/\/var\/www\/html\///g'`"
    dir="`/bin/echo ${file} | /usr/bin/awk 'BEGIN {FS = "/";OFS = "/";} {$NF=""}1'`"
    /bin/tar auf ${HOME}/webrootsync/${syncfile} ${file} 
done

if ( [ "`/usr/bin/cmp --silent ${HOME}/webrootsync/webrootsync.${ip}.tar ${HOME}/config/webrootsynctunnel/webrootsync.${ip}.tar || /bin/echo 'files are different'`" != "" ] || [ ! -f ${HOME}/config/webrootsynctunnel/webrootsync.${ip}.tar ] )
then
    /bin/cp ${HOME}/webrootsync/webrootsync.${ip}.tar ${HOME}/config/webrootsynctunnel
fi
