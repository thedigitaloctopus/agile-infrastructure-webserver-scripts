#!/bin/sh
#####################################################################################
# Description: If your application requires any post processing to be performed, then,
# this is the place to put it. Post processing is considered to be any processing which
# is required after the application is considered installed. This is the post processing
# for a joomla install. If you examine the code, you will find that this script is called
# from the build client over ssh once it considers that the application has been fully installed.
#   ***********IMPORTANT*****************
#   These post processing scipts are not run using sudo as is normally the case, this is because
#   of issues with stdin and so on. So if a command requires privilege then sudo must be used
#   on a command by command basis. This is true for all PerformPostProcessing Scripts
#   ***********IMPORTANT*****************
# Author: Peter Winter
# Date: 04/01/2017
###############################################################################################
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
#####################################################################################
#####################################################################################
#set -x

#If we are not a virgin, exit
if ( [ ! -f ${HOME}/.ssh/BUILDARCHIVECHOICE:virgin ] )
then
    exit
fi

SERVER_USER="`/bin/ls ${HOME}/.ssh/SERVERUSER:* | /usr/bin/awk -F':' '{print $NF}'`"
SERVER_USER_PASSWORD="`/bin/ls ${HOME}/.ssh/SERVERUSERPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"
PREFIX="`/bin/ls ${HOME}/.ssh/DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

credentials_available=""
database_available=""
configset=""

while ( [ "${credentials_available}" = "" ] || [ "${database_available}" = "" ] || [ "${configset}" = "" ] )
do
    credentials_available="`command="${SUDO} /bin/ls ${HOME}/config/credentials/shit" && eval ${command}`"
    database_available="`command="${SUDO} /bin/ls ${HOME}/config/databaseip" && eval ${command}`"
    configset="`command="${SUDO} /bin/ls ${HOME}/runtime/VIRGINCONFIGSET" && eval ${command}`"
    /bin/sleep 10
done

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] && [ -f  ${HOME}/runtime/SSHTUNNELCONFIGURED ] )
then
    while ( [ ! -f ${HOME}/runtime/SSHTUNNELCONFIGURED ] )
    do
        /bin/echo "Your SSH tunnel doesn't seem to be set up. Woops. Won't be getting far without that. Please take action to make sure that"
        /bin/echo "Your SSH tunnel is set up on your webserver, the appropriate script is ${HOME}/providerscripts/utilities/SetupSSHTunnel.sh"
        /bin/echo "Once this is done, press enter and we'll get on with it"
        read response
    done
    host="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    host="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    host="`command="${SUDO} /bin/ls ${HOME}/config/databaseip" && eval ${command}`"
fi

username="`command="${SUDO} /bin/sed '3q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
password="`command="${SUDO} /bin/sed '2q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
database="`command="${SUDO} /bin/sed '1q;d' ${HOME}/config/credentials/shit" && eval ${command}`"

#The default credentials for the joomla database are webmaster and password test1234 - these MUST be changed after installation

#So, by now, we know that we have a database to access and so we can perform some configuration steps to set it up as we need it
#The default database sql database is installed so that the joomla installation is completed. We also set a username and password
#for the admin account as well as a user group. Right on.
if ( ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] ) ||
     ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] ) )
then
    command="${SUDO} /bin/cp /var/www/html/installation/sql/mysql/joomla.sql /tmp/joomla.sql" && eval ${command}
    command="${SUDO} /bin/sed -i \"s/#__/${PREFIX}_/g\" /tmp/joomla.sql" && eval ${command}
    /usr/bin/mysql -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" < /tmp/joomla.sql
    /usr/bin/mysql -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" -e "INSERT INTO ${PREFIX}_users (id,name,username,email,password,params) values (42,'webmaster','webmaster','testxyz@test123.com','16d7a4fca7442dda3ad93c9a726597e4',1);"
    /usr/bin/mysql -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" -e "INSERT INTO ${PREFIX}_user_usergroup_map values (42,8);"
    /usr/bin/mysql -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" -e "UPDATE ${PREFIX}_extensions set enabled=1 where name='plg_system_cache';"
   command="${SUDO} /bin/rm /tmp/joomla.sql" && eval ${command}
fi

#We want to check if the database is accessible
/bin/echo "The default credentials for your brand new joomla site are set to: Admin name: webmaster  Admin password: test1234"
/bin/echo "Clearly, it is essential to change these to stop your site being compromised and they are just set as such to bootstrap your site building"
/bin/echo "Press <enter> to acknowledge"
read x

#OK, if we get to here, we no longer need our default installation directory. It has served us well, so, we can nuke it
command="${SUDO} /bin/rm -r /var/www/html/installation" && eval ${command}
