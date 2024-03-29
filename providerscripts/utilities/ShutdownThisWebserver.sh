#!/bin/sh
################################################################################################
# Author: Peter Winter
# Date  : 9/4/2016
# Description : Shutdown this websever, removing its IP from cloudflare NB: shutdown -h doesn't
# work from linodes and needs bespoke process because, linodes have something called "lasie"
# monitoring the linodes and it restarts them whenever they are shutdown. They have to be
# explicitly shutdown
################################################################################################
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
#################################################################################################
#################################################################################################
#set -x

/bin/echo "${0} `/bin/date`: This webserver is shutting down" >> ${HOME}/logs/MonitoringLog.dat

/bin/echo ""
/bin/echo "#######################################################################"
/bin/echo "Shutting down a webserver, please wait whilst I clean the place up first"

#make sure a backup isn't running when we shutdown because if it is it would get corrupted



if ( [ "$1" = "backup" ] && [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "backuplock.file"`" = "0" ] )
then
    /bin/echo
    /bin/echo "Making a daily and an emergency shutdown backup of your webserver for safety"
    BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
    /bin/echo "Making the special shutdown backup please wait....."
    ${HOME}/cron/BackupFromCron.sh 'SHUTDOWN' ${BUILD_IDENTIFIER} > /dev/null 2>&1
fi

/bin/echo "#######################################################################"
/bin/echo ""


ip="`${HOME}/providerscripts/utilities/GetIP.sh`"



if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "bootedwebserverips/${ip}"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "bootedwebserverips/${ip}"
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "webserverpublicips/${ip}"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "webserverpublicips/${ip}"
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "webserverips/${ip}"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "webserverips/${ip}"
fi

${HOME}/providerscripts/email/SendEmail.sh "${period} A Webserver with IP: `${HOME}/providerscripts/utilities/GetIP.sh` has been shutdown" "Webserver has been shut down"

/usr/sbin/shutdown -h now


