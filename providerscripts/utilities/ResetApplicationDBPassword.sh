set -x

/bin/echo "This script will change the database password for your application"
/bin/echo "Please enter the old password"

read old_password

while ( [ "`/bin/cat ${HOME}/config/credentials/shit | /bin/grep ${old_password}`" = "" ] )
do
    /bin/echo "That is not the old password, please enter it again"
    read old_password
done

/bin/echo "Now please enter your new password, it should begin and end with a lower case 'p' letter"
read new_password

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] )
then
    ${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "set password=\"${new_password};\""
fi

if ( [ -f ${HOME}/.ssh/APPLICATION:drupal ] )
then
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/config/credentials/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/config/drupal_settings.php
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/runtime/drupal_settings.php
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" /var/www/html/sites/default/settings.php
    ${HOME}/providerscripts/utilities/ConnectDBServer.sh "/bin/sed -i \"s/${old_password}/${new_password}/g\" ${HOME}/credentials/shit"
fi
