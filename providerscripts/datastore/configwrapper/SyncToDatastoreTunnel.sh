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
#set -x

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
    exit
fi

if ( [ -f ${HOME}/runtime/checklist.chk.new ] )
then
    /bin/mv ${HOME}/runtime/checklist.chk.new ${HOME}/runtime/checklist.chk
fi

directoriestomiss="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

if ( [ "${directoriestomiss}" = "" ] )
then
    CMD="`/usr/bin/find /var/www/html/ -type f -exec md5sum {} \;`"
else
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PERSISTASSETSTOCLOUD:0`" = "1" ] )
    then
        CMD="/usr/bin/find /var/www/html/ -type f "
    else
        CMD="/usr/bin/find /var/www/html/ -type f -not -path "

        for directorytomiss in ${directoriestomiss}
        do
            CMD=${CMD}"'/var/www/html/${directorytomiss}/*' -not -path "
            CMD=${CMD}"'/var/www/html/${directorytomiss}' -not -path "
        done
        CMD="`/bin/echo ${CMD} | /bin/sed 's/-not -path$//g'`"
    fi
    CMD="${CMD} -exec md5sum {} \;"
fi

eval ${CMD} > ${HOME}/runtime/checklist.chk.new

if ( [ ! -f ${HOME}/runtime/checklist.chk ] || [ "`/bin/cat ${HOME}/runtime/checklist.chk`" = "" ] )
then
   /bin/cp ${HOME}/runtime/checklist.chk.new ${HOME}/runtime/checklist.chk
else
    /usr/bin/diff ${HOME}/runtime/checklist.chk ${HOME}/runtime/checklist.chk.new | /bin/grep "^>" | /usr/bin/awk '{print $NF}' > ${HOME}/runtime/newandmodfiles.dat

    ${HOME}/applicationscripts/CleanApplicationTunnel.sh 2>/dev/null

    for file in `/bin/cat ${HOME}/runtime/newandmodfiles.dat`
    do
        destfile="`/bin/echo ${file} | /bin/sed 's/\/var\/www\/html//g'`"
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${file}  webrootsynctunnel${destfile}
    done
fi
