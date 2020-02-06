#!/bin/sh
###########################################################################################################
# Description: When we build from a snapshot it is probable that the snapshot was taken quite some time
# before now and so the code on the snapshot will be stale compared to what we have as our backups in our
# repositories, so, when we build from a snapshot, we do a sync with our repoistories or datastore to make
# sure that our codebase is up to date even when we are building from a snapshot which is a bit long in the tooth
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

WEBSITE_URL="`/bin/ls ${HOME}/.ssh/WEBSITEURL:* | /usr/bin/awk -F':' '{print $NF}'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"

if ( [ -f ${HOME}/.ssh/BUILDARCHIVECHOICE:baseline ] )
then
    exit
fi

HOME="`/bin/ls -ld /home/X*X | /usr/bin/awk '{print $NF}'`"

APPLICATION_REPOSITORY_PROVIDER="${1}"
APPLICATION_REPOSITORY_USERNAME="${2}"
APPLICATION_REPOSITORY_PASSWORD="${3}"
APPLICATION_REPOSITORY_OWNER="${4}"
BUILD_ARCHIVE_CHOICE="${5}"
DATASTORE_PROVIDER="${6}"
BUILD_IDENTIFIER="${7}"
WEBSITE_NAME="${8}"

if ( [ -f /var/www/html/.htaccess ] )
then
    /bin/mv /var/www/html/.htaccess /tmp
fi

/bin/mv /var/www/html /var/www/html.$$
/bin/mkdir -p /var/www/html
/bin/chmod 755 /var/www/html
/bin/chown www-data.www-data /var/www/html
cd /var/www/html
/usr/bin/git init

/bin/touch ${HOME}/runtime/ENABLEDTOSYNC

APPLICATION_REPOSITORY_NAME="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-${BUILD_ARCHIVE_CHOICE}-${BUILD_IDENTIFIER}"
${HOME}/providerscripts/git/GitPull.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_NAME} > /dev/null 2>&1

if ( [ "`/bin/ls -l /var/www/html | /usr/bin/wc -l`" -lt "10" ] )
then
    cd ${HOME}
    ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_PROVIDER}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${BUILD_ARCHIVE_CHOICE}/applicationsourcecode.tar.gz"
    /bin/tar xvfz ${HOME}/applicationsourcecode.tar.gz
    /bin/mv ${HOME}/tmp/backup/* /var/www/html
    /bin/rm -rf ${HOME}/tmp
fi

if ( [ -f /tmp/.htaccess ] )
then
    /bin/mv /tmp/.htaccess /var/www/html
fi

/bin/chown -R www-data.www-data /var/www/html

while ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
do
    /bin/sleep 10
done

/bin/rm ${HOME}/config/APPLICATION_DB_CONFIGURED
/bin/rm ${HOME}/config/UPDATE*
/bin/rm ${HOME}/config/DB*
/sbin/shutdown -r now

