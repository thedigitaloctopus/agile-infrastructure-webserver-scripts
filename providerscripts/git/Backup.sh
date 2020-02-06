#!/bin/sh
###################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This is the backup script for the webroot. It can be run hourly, daily, weekly,
# monthly or bimonthly.
# The backup is writen to a repository. Please make sure these repositories are kept private as
# if you have deployed a website which has sensitive information as part of its sourcecode, then,
# there are people who trawl public repositories and look for sensitive information like access keys
# and so on with the idea of using them for unauthorised activity
###################################################################################################
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

WEBSITE_URL="`/bin/ls ${HOME}/.ssh/WEBSITEURL:* | /usr/bin/awk -F':' '{print $NF}'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME="`/bin/ls ${HOME}/.ssh/WEBSITEDISPLAYNAME:* | /usr/bin/awk -F':' '{print $NF}' | /bin/sed 's/_/ /g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"

if ( [ "$1" = "" ] || [ "$2" = "" ] )
then
    /bin/echo "This script needs to be run with the <build periodicity> parameter and the <build identifier> parameter"
    exit
fi

if ( [ ! -f ${HOME}/config/INSTALLEDSUCCESSFULLY ] )
then
    exit
fi

/bin/echo "${0} `/bin/date`: Performing the backup of the master webroot" >> ${HOME}/logs/MonitoringLog.dat
/usr/bin/find /var/www/html -name "sed*" -print -delete

/bin/rm -r /tmp/backup
/bin/mkdir /tmp/backup
cd /tmp/backup
#/bin/rm -r ${HOME}/.git

if ( [ -f ${HOME}/.ssh/PERSISTASSETSTOCLOUD:1 ] )
then
    dirstoomit="`/bin/ls ${HOME}/.ssh/DIRECTORIESTOMOUNT:* | /usr/bin/awk -F':' '{$1=""; print $0}' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
    command="/usr/bin/rsync -av --exclude='"
    for dir in ${dirstoomit}
    do
        command="${command}/${dir}' --exclude='"
    done
    command="`/bin/echo ${command} | /usr/bin/awk '{$NF=""; print $0}'` /var/www/html/* /tmp/backup"
    eval ${command}
else
    /usr/bin/rsync -av /var/www/html/* /tmp/backup
fi

#/usr/bin/find -type d -name .git -exec /bin/rm -rf {} \;

/bin/echo "${0} `/bin/date`: Running a backup" >> ${HOME}/logs/MonitoringLog.dat

. ${HOME}/providerscripts/utilities/SetupInfrastructureIPs.sh

${HOME}/providerscripts/application/customise/CustomiseBackupByApplication.sh

APPLICATION_REPOSITORY_USERNAME="`/bin/ls ${HOME}/.ssh | /bin/grep 'APPLICATIONREPOSITORYUSERNAME' | /usr/bin/awk -F':' '{print $NF}'`"
APPLICATION_REPOSITORY_PASSWORD="`/bin/ls ${HOME}/.ssh | /bin/grep 'APPLICATIONREPOSITORYPASSWORD' | /usr/bin/awk -F':' '{print $NF}'`"
APPLICATION_REPOSITORY_PROVIDER="`/bin/ls ${HOME}/.ssh/APPLICATIONREPOSITORYPROVIDER:* | /usr/bin/awk -F':' '{print $NF}'`"
APPLICATION_REPOSITORY_OWNER="`/bin/ls ${HOME}/.ssh/APPLICATIONREPOSITORYOWNER:* | /usr/bin/awk -F':' '{print $NF}'`"
DATASTORE_CHOICE="`/bin/ls ${HOME}/.ssh/DATASTORECHOICE:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "$1" = "HOURLY" ] )
then
    period="hourly"
fi
if ( [ "$1" = "DAILY" ] )
then
    period="daily"
fi
if ( [ "$1" = "WEEKLY" ] )
then
    period="weekly"
fi
if ( [ "$1" = "MONTHLY" ] )
then
    period="monthly"
fi
if ( [ "$1" = "BIMONTHLY" ] )
then
    period="bimonthly"
fi

BUILD_IDENTIFIER="$2"
ip="`${HOME}/providerscripts/utilities/GetIP.sh`"


if ( [ -f /tmp/backup/index.php.backup ] )
then
    /bin/cp /tmp/backup/index.php /tmp/backup/index.php.veteran
    /bin/cp /tmp/backup/index.php.backup /tmp/backup/index.php
fi

${HOME}/providerscripts/git/DeleteRepository.sh "${APPLICATION_REPOSITORY_USERNAME}" "${APPLICATION_REPOSITORY_PASSWORD}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}" "${period}" "${BUILD_IDENTIFIER}" "${APPLICATION_REPOSITORY_PROVIDER}"
${HOME}/providerscripts/git/CreateRepository.sh "${APPLICATION_REPOSITORY_USERNAME}" "${APPLICATION_REPOSITORY_PASSWORD}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}" "${period}" "${BUILD_IDENTIFIER}" "${APPLICATION_REPOSITORY_PROVIDER}"
/bin/systemd-inhibit --why="Persisting sourcecode to git repo" ${HOME}/providerscripts/git/GitPushSourcecode.sh "." "Automated Backup" "${APPLICATION_REPOSITORY_PROVIDER}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-${period}-${BUILD_IDENTIFIER}"

if ( [ -f ${HOME}/.ssh/SUPERSAFEWEBROOT:1 ] )
then
   # /bin/rm -r /tmp/backup/.git
    ${HOME}/providerscripts/datastore/MountDatastore.sh "${DATASTORE_CHOICE}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}"
    ${HOME}/providerscripts/application/processing/BundleSourcecodeByApplication.sh "/tmp/backup"
    ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${DATASTORE_CHOICE} "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}/applicationsourcecode.tar.gz.BACKUP"
    ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}/applicationsourcecode.tar.gz" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}/applicationsourcecode.tar.gz.BACKUP"
    /bin/systemd-inhibit --why="Persisting sourcecode to datastore" ${HOME}/providerscripts/datastore/PutToDatastore.sh "${DATASTORE_CHOICE}" /tmp/applicationsourcecode.tar.gz "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${period}"
fi

${HOME}/providerscripts/application/customise/UnCustomiseBackupByApplication.sh

/bin/rm -rf /tmp/backup
#If you want to be notified every time there is a backup, then, uncomment these lines please
#${HOME}/providerscripts/email/SendEmail.sh "${period} Webroot Backup has been completed" "Webroot backup has completed"
#bin/echo "${0} `/bin/date`: Notification email sent that a webroot backup has been completed" >> ${HOME}/logs/MonitoringLog.dat

