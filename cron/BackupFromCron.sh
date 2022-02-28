#!/bin/bash
############################################################################################################################
# Description: This script will perform a backup of the webroot when it is called from cron
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

#In the case where there are multiple webservers running, we don't want backups to spawn concurrently,
#so put in a random delay before the backup begins. This will make sure that it is unlikely two or more
#backup processes will run concurrently. This is necessary because the config directory where the lock is
#created is backed by s3fs and so it takes some seconds for the lock file to be created and we need to
#guard against that

delay1=(10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 260 270 280 290 300)
delay2=(10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 260 270 280 290 300)

delay1="`/bin/echo ${delay1[RANDOM%30]}`"
delay2="`/bin/echo ${delay2[RANDOM%30]}`"

delay="`/usr/bin/expr ${delay1} + ${delay2}`"

/bin/sleep ${delay}

#lockfile=${HOME}/config/

#/usr/bin/find ${lockfile} -mmin +20 -type f -exec rm -fv {} \;

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "backuplock.file"`" = "0" ] )
then
    /usr/bin/touch ${HOME}/runtime/backuplock.file
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/backuplock.file 
    ${HOME}/providerscripts/git/Backup.sh "${periodicity}" "${buildidentifier}"
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "backuplock.file"
else
    /bin/echo "script already running"
fi

