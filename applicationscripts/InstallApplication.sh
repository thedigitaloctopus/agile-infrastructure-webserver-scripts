#!/bin/sh
###########################################################################################################
# Description: This script will  install an application sourcecode. First of all it looks in the git repo
# and then in the datastore.
# Author: Peter Winter
# Date: 05/02/2017
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
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"

/bin/rm -r /var/www/html/*
/bin/rm -r /var/www/html/.*
cd /var/www/html
/usr/bin/git init

INSTALLED_VIRGIN_APPLICATION="0"
INSTALLED_VIRGIN_APPLICATION="`${HOME}/providerscripts/application/configuration/InstallVirginDeploymentByApplication.sh ${BASELINE_SOURCECODE_REPOSITORY}`"
if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] && [ "${INSTALLED_VIRGIN_APPLICATION}" = "0" ] )
then
    ${HOME}/providerscripts/git/GitPull.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${BASELINE_SOURCECODE_REPOSITORY}
    ${HOME}/providerscripts/email/SendEmail.sh "AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from repository: ${BASELINE_SOURCECODE_REPOSITORY} has been installed"
elif ( [ "${INSTALLED_VIRGIN_APPLICATION}" = "0" ] )
then
    APPLICATION_REPOSITORY_NAME="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-${BUILD_ARCHIVE_CHOICE}-${BUILD_IDENTIFIER}"
    ${HOME}/providerscripts/git/GitPull.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_REPOSITORY_NAME}

    #If we can't get our sourcecode from the repo try the datastore
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh SUPERSAFEWEBROOT:1`" ]  && [ "`/bin/ls -l /var/www/html | /usr/bin/wc -l`" -lt "10" ] )
    then
        cd ${HOME}
        ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_PROVIDER}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${BUILD_ARCHIVE_CHOICE}/applicationsourcecode.tar.gz"
        /bin/tar xvfz ${HOME}/applicationsourcecode.tar.gz
        /bin/mv ${HOME}/tmp/backup/* /var/www/html
        /bin/rm -rf ${HOME}/tmp
        ${HOME}/providerscripts/email/SendEmail.sh "AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from the datastore: ${BUILD_ARCHIVE_CHOICE} has been installed"
    else
        ${HOME}/providerscripts/email/SendEmail.sh "AN APPLICATION HAS BEEN INSTALLED" "The application sourcecode from repository: ${APPLICATION_REPOSITORY_NAME} has been installed"

    fi
fi
/bin/rm -rf /var/www/html/.git
