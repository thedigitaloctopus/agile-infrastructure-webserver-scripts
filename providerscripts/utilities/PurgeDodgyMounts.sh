#!/bin/sh
###################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: SSHFS sometimes doesn't mount correctly. So, the idea is that in that
# case, we get rid of the failed mount ASAP and the system will then try and do the
# sshfs mount again.
###################################################################################
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
######################################################################################
######################################################################################

mountpoints="`/bin/ls ${HOME}/.ssh/DIRECTORIESTOMOUNT:* | /usr/bin/awk -F':' '!($1="")' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g'`"

for mountpoint in ${mountpoints}
do

    if ( [ "`/bin/ls /var/www/html/${mountpoint} 2>&1 | /bin/grep 'Transport'`" != "" ] )
    then
        /bin/umount -f /var/www/html/${mountpoint}
    fi
done
