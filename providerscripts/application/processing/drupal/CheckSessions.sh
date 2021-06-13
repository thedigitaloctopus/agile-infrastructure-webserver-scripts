set -x

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] )
then
    prefix="`/bin/cat /var/www/html/dpb.dat`"

    if ( [ "`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "SELECT count(*) from ${prefix}_sessions" | /usr/bin/wc -l`" != "0" ] )
    then
        /bin/echo "SESSION"
    else
       /bin/echo "NOT SESSION"
    fi
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] )
then
   prefix="`/bin/cat /var/www/html/dpb.dat`"

   if ( [ "`${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh "select count(*) from ${prefix}_sessions;" raw 2>/dev/null | /bin/sed 's/ //g'`" = "0" ] )
   then
       /bin/echo "SESSION"
   else
       /bin/echo "NOT SESSION"
   fi
fi
