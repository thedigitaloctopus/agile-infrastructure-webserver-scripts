set -x

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

   if ( [ "${success}" = "yes" ] )
   then
       /bin/echo "TRUNCATED"
   else
       /bin/echo "NOT TRUNCATED"
   fi
fi
