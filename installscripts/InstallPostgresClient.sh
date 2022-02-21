
#!/bin/sh
######################################################################################################
# Description: This script will install the postgres client
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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

if ( [ "${1}" != "" ] )
then
    BUILDOS="${1}"
fi

if ( [ "${BUILDOS}" = "ubuntu" ] )
then
    version="`/usr/bin/curl https://www.postgresql.org/ftp/source/ | /bin/grep -o ">v.*<\/a" | /bin/sed 's/^>//g' | /bin/sed 's/<.*//g' | /bin/grep -v "rc" | /bin/grep -v "alpha" | /bin/grep -v "beta" | /usr/bin/head -1 | /bin/sed 's/v//g'`"

    /usr/bin/wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    /bin/echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
    ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -y install postgresql-client-`/bin/echo ${version} | /usr/bin/awk -F'.' '{print $1}'`
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    version="`/usr/bin/curl https://www.postgresql.org/ftp/source/ | /bin/grep -o ">v.*<\/a" | /bin/sed 's/^>//g' | /bin/sed 's/<.*//g' | /bin/grep -v "rc" | /bin/grep -v "alpha" | /bin/grep -v "beta" | /usr/bin/head -1 | /bin/sed 's/v//g'`"

    /usr/bin/wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    /bin/echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
    ${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -y install postgresql-client-`/bin/echo ${version} | /usr/bin/awk -F'.' '{print $1}'`
fi

