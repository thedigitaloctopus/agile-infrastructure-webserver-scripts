#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: Making sure that the config directories are set and created
#######################################################################################
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

#Try repeatedly because I have seen single attempts to create directories fail over S3FS
while ( [ ! -d ${HOME}/config/beingbuiltips ] )
do
    /bin/mkdir -p ${HOME}/config/beingbuiltips
    /bin/chmod 700 ${HOME}/config/beingbuiltips
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/webserverpublicips ] )
do
    /bin/mkdir -p ${HOME}/config/webserverpublicips
    /bin/chmod 700 ${HOME}/config/webserverpublicips
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/webserverips ] )
do
    /bin/mkdir -p ${HOME}/config/webserverips
    /bin/chmod 700 ${HOME}/config/webserverips
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/databaseip ] )
do
    /bin/mkdir -p ${HOME}/config/databaseip
    /bin/chmod 700 ${HOME}/config/databaseip
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/databasepublicip ] )
do
    /bin/mkdir -p ${HOME}/config/databasepublicip
    /bin/chmod 700 ${HOME}/config/databasepublicip
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/bootedwebserverips ] )
do
    /bin/mkdir -p ${HOME}/config/bootedwebserverips
    /bin/chmod 700 ${HOME}/config/bootedwebserverips
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/shuttingdownwebserverips ] )
do
    /bin/mkdir -p ${HOME}/config/shuttingdownwebserverips
    /bin/chmod 700 ${HOME}/config/shuttingdownwebserverips
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/autoscalerip ] )
do
    /bin/mkdir -p ${HOME}/config/autoscalerip
    /bin/chmod 700 ${HOME}/config/autoscalerip
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/autoscalerpublicip ] )
do
    /bin/mkdir -p ${HOME}/config/autoscalerpublicip
    /bin/chmod 700 ${HOME}/config/autoscalerpublicip
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/buildclientip ] )
do
    /bin/mkdir -p ${HOME}/config/buildclientip
    /bin/chmod 700 ${HOME}/config/buildclientip
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/credentials ] )
do
    /bin/mkdir -p ${HOME}/config/credentials
    /bin/chmod 700 ${HOME}/config/credentials
    /bin/sleep 5
done
while ( [ ! -d ${HOME}/config/webrootsynctunnel ] )
do
    /bin/mkdir -p ${HOME}/config/webrootsynctunnel
    /bin/chmod 700 ${HOME}/config/webrootsynctunnel
    /bin/sleep 5
done

if ( [ ! -d ${HOME}/config/ssl ] )
then
    /bin/mkdir -p ${HOME}/config/ssl
    /bin/chmod 700 ${HOME}/config/ssl
fi
