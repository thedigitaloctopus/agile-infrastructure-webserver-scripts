#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/06/2021
# Description: This will truncate the cache tables of a fresh drupal install. This is 
# necessary because, during a drupal install, there is a tendency for cache pollution
# which causes problems and makes a mess of the install. This is my best attempt to 
# clear out the caching system during the install process such that we end up with a 
# clean install. 
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
    
   cache_tables="` ${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh " select table_schema as database_name, table_name from information_schema.tables where table_type = 'BASE TABLE' and table_name like '%cache%' order by table_schema, table_name;" | /bin/grep -v 'database_' | /bin/grep -v 'table_' | /usr/bin/awk '{print $NF}'`"

   success="yes"

   for cache_table in ${cache_tables}
   do
       ${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "TRUNCATE ${cache_table};"
       
       if ( [ "$?" != "0" ] )
       then
           success="no"
       fi
       
   done

   if ( [ "${success}" = "yes" ] && [ "`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "select count(*) from ${prefix}_cache_data;" raw 2>/dev/null`" = "0" ] )
   then
       /bin/echo "TRUNCATED"
   else
       /bin/echo "NOT TRUNCATED"
   fi
fi
