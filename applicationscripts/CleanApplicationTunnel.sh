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

APPLICATION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATION'`"

if ( [ "${APPLICATION}" = "joomla" ] )
then
    /bin/sed -i '/\/var\/www\/html\/administrator\/cache\//d' ${HOME}/runtime/newandmodfiles.dat
    /bin/sed -i '/\/var\/www\/html\/administrator\/logs\//d' ${HOME}/runtime/newandmodfiles.dat
    /bin/sed -i '/\/var\/www\/html\/cache\//d' ${HOME}/runtime/newandmodfiles.dat
    /bin/sed -i '/\/var\/www\/html\/logs\//d' ${HOME}/runtime/newandmodfiles.dat
    /bin/sed -i '/\/var\/www\/html\/tmp\//d' ${HOME}/runtime/newandmodfiles.dat
elif ( [ "${APPLICATION}" = "wordpress" ] )
then
    /bin/sed -i '/\/var\/www\/html\/wp-content\/uploads\/session/d' ${HOME}/runtime/newandmodfiles.dat
elif ( [ "${APPLICATION}" = "moodle" ] )
then
    /bin/sed -i '/\/var\/www\/html\/moodledata\/cache\//d' ${HOME}/runtime/newandmodfiles.dat
elif ( [ "${APPLICATION}" = "drupal" ] )
then
    /bin/sed -i '/\/var\/www\/html\/logs\//d' ${HOME}/runtime/newandmodfiles.dat
    /bin/sed -i '/\/var\/www\/html\/tmp\//d' ${HOME}/runtime/newandmodfiles.dat
fi
