#!/bin/sh
###############################################################################################
# Description: This script will set the permissions correctly for the webroot. It is called periodically
# from cron to make sure that any new additions to the webroot filesystem also have the correct permissions.
# Author: Peter Winter
# Date: 07/01/2017
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
##########################################################################################
##########################################################################################
#set -x

directoriestomiss="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

CMD="/usr/bin/find /var/www/html/ -not -path "

for directorytomiss in ${directoriestomiss}
do
    CMD=${CMD}"'/var/www/html/${directorytomiss}/*' -not -path "
done

CMD="`/bin/echo ${CMD} | /bin/sed 's/-not -path$//g'`"
CMD="${CMD} -exec chown www-data:www-data {} \;"

CMD1="/usr/bin/find /var/www/html/ -type d -not -path "

for directorytomiss in ${directoriestomiss}
do
    CMD1=${CMD1}"'/var/www/html/${directorytomiss}/*' -not -path "
done

CMD1="`/bin/echo ${CMD1} | /bin/sed 's/-not -path$//g'`"
CMD1="${CMD1} -exec chmod 755 {} \;"
CMD2="/usr/bin/find /var/www/html/ -type f -not -path "

for directorytomiss in ${directoriestomiss}
do
    CMD2=${CMD2}"'/var/www/html/${directorytomiss}/*' -not -path "
done

CMD2="`/bin/echo ${CMD2} | /bin/sed 's/-not -path$//g'`"
CMD2="${CMD2} -not -name "*.cgi" -not -name "*.pl" -not -name "*.py" -exec chmod 644 {} \;"

eval "${CMD}"
eval "${CMD1}"
eval "${CMD2}"

/bin/chmod 400 /var/www/html/.htaccess
/bin/chmod -R 700 ${HOME}/.ssh/*
/bin/chmod 400 ${HOME}/.ssh/Super.sh


/usr/bin/find /var/www/html -type f -name "*.pl" -exec chmod 755 {} \;
/usr/bin/find /var/www/html -type f -name "*.cgi" -exec chmod 755 {} \;
/usr/bin/find /var/www/html -type f -name "*.py" -exec chmod 755 {} \;


