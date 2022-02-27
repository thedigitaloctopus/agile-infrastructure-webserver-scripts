#!/bin/sh
#####################################################################################
# Description: This will regulate the webroot syncing process and is called daily 
# from cron
# Date: 16/11/2016
# Author: Peter Winter
#####################################################################################
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
############################################################################
############################################################################
#set -x
#Switch off scaling for 1 hour prior to sync purge
while ( [ ! -f ${HOME}/config/webrootsynctunnel/switchoffscalingpriortosyncpurge ] )
do
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh webrootsynctunnel/switchoffscalingpriortosyncpurge 
    /bin/sleep 10
done

/bin/sleep 3600

while ( [ ! -f ${HOME}/config/webrootsynctunnel/syncpurge ] || [ -f ${HOME}/config/webrootsynctunnel/switchoffscalingpriortosyncpurge ] )
do
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh webrootsynctunnel/syncpurge
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "webrootsynctunnel/switchoffscalingpriortosyncpurge"
    /bin/sleep 10
done

/bin/sleep 720 

while ( [ -f ${HOME}/config/webrootsynctunnel/syncpurge ] )
do
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "webrootsynctunnel/syncpurge"
    /bin/sleep 10
done
