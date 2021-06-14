#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/07/2016
# Description: This is a simple way of checking that drupal has created a user during install 
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
#######################################################################################
#######################################################################################
#set -x
set -f

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] )
then
    prefix="`/bin/cat /var/www/html/dpb.dat`"
    
    user="`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "SELECT * from ${prefix}_users" | /bin/sed 's/ //g' | /bin/sed '/^$/d' | /usr/bin/wc -l`"
    
    if ( [ "${user}" = "2" ] && [ "${user}" != "" ] )
    then
        /bin/echo "USER ADDED"
    else
       /bin/echo "NO USER ADDED"
    fi
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] )
then
   prefix="`/bin/cat /var/www/html/dpb.dat`"
   
   user="`${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh "select * from ${prefix}_users_field_data;" "raw" | /bin/sed 's/ //g' | /bin/sed '/^$/d' | /usr/bin/wc -l`"

   if ( [ "${user}" = "2" ] && [ "${user}" != "" ] )
   then
       /bin/echo "USER ADDED"
   else
       /bin/echo "NO USER ADDED"
   fi
fi
