#!/bin/bash
############################################################################################################################
# Description: This script will make a backup of the assets directory within S3
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

lockfile=${HOME}/config/backups3todatastorelock.file

/bin/rm ${lockfile}

delay=(10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 260 270 280 290 300)
delay="`/bin/echo ${delay[RANDOM%30]}`"
sleep ${delay}

if ( [ ! -f ${lockfile} ] )
then
    /usr/bin/touch ${lockfile}
    ${HOME}/providerscripts/datastore/BackupS3ToDatastore.sh
    /bin/rm ${lockfile}
else
    /bin/echo "script already running"
fi
