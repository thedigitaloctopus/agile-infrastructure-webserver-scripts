#!/bin/sh
####################################################################################
# Description: This script will archive the application on an Application by Application
# basis. You can implement application specific bundling in the subdirs as per the examples
# Date: 16-11-2016
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
##################################################################################
##################################################################################
#set -x

directory="$1"
mounteddirectories="`/bin/ls ${HOME}/.ssh/DIRECTORIESTOMOUNT:* | /bin/sed 's/.*DIRECTORIESTOMOUNT://g' | /bin/sed 's/:/ /g' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"
CMD="/bin/tar cPvfz /tmp/applicationsourcecode.tar.gz ${directory}/* "

for mounteddirectory in ${mounteddirectories}
do
    if ( [ ! -f ${HOME}/.ssh/BUILDARCHIVECHOICE:virgin ] && [ ! -f ${HOME}/.ssh/BUILDARCHIVECHOICE:baseline ] )
    then
        CMD=${CMD}"--exclude=\"${directory}/${mounteddirectory}\" "
    fi
done

eval ${CMD}

