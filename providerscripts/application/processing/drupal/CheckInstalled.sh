set -x

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] )
then
    prefix="`/bin/cat /var/www/html/dpb.dat`"

    if ( [ "`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "SELECT * from ${prefix}_users" | /usr/bin/wc -l`" != "0" ] )
    then
        /bin/echo "INSTALLED"
    else
       /bin/echo "NOT INSTALLED"
    fi
fi
