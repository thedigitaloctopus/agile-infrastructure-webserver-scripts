#!/bin/sh
###########################################################################################################
# Description: This script will remove temporary files from the application websync tunnel archives
#              You can add cases here for your application to keep the archives clean and minimal
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

APPLICATION="`/bin/ls ${HOME}/.ssh/APPLICATION:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${APPLICATION}" = "joomla" ] )
then
    archives="`/bin/ls ${HOME}/config/webrootsynctunnel/webroot*`"
    for archive in ${archives}
    do
        /bin/tar -vf ${archive} --wildcards --delete cache*
        /bin/tar -vf ${archive} --wildcards --delete session*
    done
elif ( [ "${APPLICATION}" = "wordpress" ] )
then
    archives="`/bin/ls ${HOME}/config/webrootsynctunnel/webroot*`"
    for archive in ${archives}
    do
        /bin/tar -vf ${archive} --wildcards --delete wp-content/uploads/sess*
    done
elif ( [ "${APPLICATION}" = "moodle" ] )
then
    :
elif ( [ "${APPLICATION}" = "drupal" ] )
then
    :
fi
