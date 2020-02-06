#!/bin/bash
############################################################################################################
# Description: This script will purge any dodgy mounts when called from cron.
# A dodgy mount can happen with sshfs where it doesn't fully connect. In that case, we try and clean it
# up and remount
# Date: 16/11/2016
# Author: Peter Winter
###########################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

periodicity="${1}"
buildidentifier="${2}"

lockfile=${HOME}/runtime/purgelock.file

if ( [ ! -f ${lockfile} ] )
then
    /usr/bin/touch ${lockfile}
    ${HOME}/providerscripts/utilities/PurgeDodgyMounts.sh
    /bin/rm ${lockfile}
else
    /bin/echo "script already running"
fi
