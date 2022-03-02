
#!/bin/sh
######################################################################################################
# Description: This script will install python pip
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
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y install python3-magic
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -qq -y -f install python3-pip
    /bin/rm /usr/bin/python
    /bin/ln -s /usr/bin/python3 /usr/bin/python
    /bin/rm /usr/bin/pip
    /bin/ln /usr/bin/pip3 /usr/bin/pip
    /usr/bin/pip install --default-timeout=100 future
fi

if ( [ "${BUILDOS}" = "debian" ] )
then
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y install python3-magic
    /usr/bin/apt-get -o DPkg::Lock::Timeout=-1  -qq -y -f install python3-pip
    /bin/rm /usr/bin/python
    /bin/ln -s /usr/bin/python3 /usr/bin/python
    /bin/rm /usr/bin/pip
    /bin/ln /usr/bin/pip3 /usr/bin/pip
    /usr/bin/pip install --default-timeout=100 future
fi

