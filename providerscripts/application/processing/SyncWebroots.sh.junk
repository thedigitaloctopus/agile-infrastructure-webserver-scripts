#!/bin/sh
########################################################################################
# Description: This script will apply any webroot updates to our local webroot. In other
# words, if one machine has an updated webroot, the updates will fo through the webroottunnel
# (the shared directory system between webservers) and be copied to out local webroot
# Author: Peter Winter
# Date: 04/01/2017
########################################################################################
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
#####################################################################################
#####################################################################################
set -x

directoriestomiss="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

if ( [ "${directoriestomiss}" = "" ] )
then
    CMD="`/usr/bin/find /var/www/html/ -cmin -6 -mmin -6 -type f`"
else
    CMD="/usr/bin/find /var/www/html/ -type f -mmin -6 -cmin -6 -not -path "

    for directorytomiss in ${directoriestomiss}
    do
        CMD=${CMD}"'/var/www/html/${directorytomiss}/*' -not -path "
    done

    CMD="`/bin/echo ${CMD} | /bin/sed 's/-not -path$//g'`"
fi

if ( [ ! -f ${HOME}/runtime/webroottotunnelmanifest.previous ] )
then
    eval ${CMD} > ${HOME}/runtime/webroottotunnelmanifest.previous
else
    eval ${CMD} > ${HOME}/runtime/webroottotunnelmanifest.current
    /usr/bin/diff ${HOME}/runtime/webroottotunnelmanifest.previous ${HOME}/runtime/webroottotunnelmanifest.current > ${HOME}/runtime/webroottotunnelmanifest.diff
    /bin/mv ${HOME}/runtime/webroottotunnelmanifest.current ${HOME}/runtime/webroottotunnelmanifest.previous
    /bin/grep '^> ' ${HOME}/runtime/webroottotunnelmanifest.diff | /bin/sed 's/> //g' > ${HOME}/runtime/webroottotunnelmanifest.diff.clean
fi
