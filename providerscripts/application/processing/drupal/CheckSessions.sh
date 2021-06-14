#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/07/2016
# Description: This is a simple way of checking that drupal has initialised a session correctly. 
# The way I check is just to check if any sessions have been added to the _sessions table. 
# If sessions exist, then, we can assume that sessions are being created correctly. 
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

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] )
then
    prefix="`/bin/cat /var/www/html/dpb.dat`"
    
    session="`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "SELECT * from ${prefix}_sessions" | /usr/bin/wc -l`"
    
    if ( [ "${session}" != "0" ] )
    then
        /bin/echo "SESSION"
    else
       /bin/echo "NOT SESSION"
    fi
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] )
then
   prefix="`/bin/cat /var/www/html/dpb.dat`"
   
   session="`${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh "select * from ${prefix}_sessions;" raw 2>/dev/null | /bin/sed 's/ //g' | /usr/bin/wc -l`"

   if ( [ "${session}" != "0" ] && [ "${session}" != "" ] )
   then
       /bin/echo "SESSION"
   else
       /bin/echo "NOT SESSION"
   fi
fi
