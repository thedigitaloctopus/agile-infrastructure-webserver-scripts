#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/06/2021
# Description: You can use this script to reset your application password. This will reset
# the database password in your mysql or postgresql database
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

while ( [ "`/bin/echo ${new_password} | grep "^p" | grep "p$"`" = "" ] )
do
    /bin/echo "Your password needs to begin and end with a small letter p"
    /bin/echo "Please re-enter your password"
    read new_password
done

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] )
then
    ${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "set password=\"${new_password};\""
fi

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Postgres ] )
then
    DB_N="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"
    ${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh "ALTER USER ${DB_N} WITH PASSWORD \"${new_password}\"";
fi

if ( [ -f ${HOME}/.ssh/APPLICATION:joomla ] )
then
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/config/credentials/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/config/joomla_configuration.php
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" /var/www/html/configuration.php
    ${HOME}/providerscripts/utilities/ConnectDBServer.sh "/bin/sed -i \"s/${old_password}/${new_password}/g\" ${HOME}/credentials/shit"
fi

if ( [ -f ${HOME}/.ssh/APPLICATION:wordpress ] )
then
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/config/credentials/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/config/wordpress_config.php
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/runtime/wordpress_config.php
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" /var/www/wp-config.php
    ${HOME}/providerscripts/utilities/ConnectDBServer.sh "/bin/sed -i \"s/${old_password}/${new_password}/g\" ${HOME}/credentials/shit"
fi

if ( [ -f ${HOME}/.ssh/APPLICATION:drupal ] )
then
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/config/credentials/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/config/drupal_settings.php
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/runtime/drupal_settings.php
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/sites/default/settings.php
    ${HOME}/providerscripts/utilities/ConnectDBServer.sh "/bin/sed -i \"s/${old_password}/${new_password}/g\" ${HOME}/credentials/shit"
fi

if ( [ -f ${HOME}/.ssh/APPLICATION:moodle ] )
then
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/config/credentials/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" ${HOME}/shit
    /bin/sed -i "s/${old_password}/${new_password}/g" /var/www/html/moodle/config.php
    ${HOME}/providerscripts/utilities/ConnectDBServer.sh "/bin/sed -i \"s/${old_password}/${new_password}/g\" ${HOME}/credentials/shit"
fi