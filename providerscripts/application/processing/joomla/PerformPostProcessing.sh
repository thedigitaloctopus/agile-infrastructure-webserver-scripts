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
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] ) 
then
    exit
fi

SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
PREFIX="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPREFIX'`"
#PREFIX="`/bin/ls ${HOME}/.ssh/DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}' 2>/dev/null`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"

SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"


#Set a prefix for our database tables. Make sure we only ever set one in the case where the script runs more than once
#and exits for some reason.
#if ( [ "${PREFIX}" = "" ] && [ ! -f /var/www/html/dpb.dat ] )
#then
#    #PREFIX="`< /dev/urandom tr -dc a-z | head -c${1:-6};echo;`"
#    PREFIX="`/usr/bin/date +%s | /usr/bin/sha256sum | /usr/bin/base64 | /usr/bin/head -c 6; echo`"
#    ${HOME}/providerscripts/utilities/StoreConfigValue.sh "DBPREFIX" "${PREFIX}"
#    /bin/echo "${PREFIX}" > /var/www/html/dpb.dat
#else
#    PREFIX="`command="${SUDO} /bin/cat /var/www/html/dpb.dat" && eval ${command}`"
#fi

if ( [ "${PREFIX}" = "" ] )
then
    PREFIX="`/usr/bin/date +%s | /usr/bin/sha256sum | /usr/bin/base64 | /usr/bin/head -c 6; echo`"
fi

${HOME}/providerscripts/utilities/StoreConfigValue.sh "DBPREFIX" "${PREFIX}"
/bin/echo "${PREFIX}" > /var/www/html/dpb.dat

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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    host="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
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
if ( ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ]  ) || ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] ) )
then
    installationstatus=""
    if ( [ -d /var/www/html/installation ] )
    then 
        if ( [ -f /var/www/html/installation/sql/mysql/joomla.sql ] )
        then
            installationstatus="1"
            command="${SUDO} /bin/cp /var/www/html/installation/sql/mysql/joomla.sql /tmp/joomla.sql" && eval ${command}
            command="${SUDO} /bin/sed -i \"s/#__/${PREFIX}_/g\" /tmp/joomla.sql" && eval ${command}
            command="${SUDO} /bin/sed -i '1s/^/SET SESSION sql_require_primary_key=0;\n/' /tmp/joomla.sql" && eval ${command}
        else
            installationstatus="2"
            command="${SUDO} /bin/sed -i '1s/^/SET SESSION sql_require_primary_key=0;\n/' /var/www/html/installation/sql/mysql/base.sql" && eval ${command}
            command="${SUDO} /bin/sed -i '1s/^/SET SESSION sql_require_primary_key=0;\n/' /var/www/html/installation/sql/mysql/extensions.sql" && eval ${command}
            command="${SUDO} /bin/sed -i '1s/^/SET SESSION sql_require_primary_key=0;\n/' /var/www/html/installation/sql/mysql/supports.sql" && eval ${command}
            command="${SUDO} /bin/cp /var/www/html/installation/sql/mysql/base.sql /tmp/base.sql" && eval ${command}
            command="${SUDO} /bin/cp /var/www/html/installation/sql/mysql/extensions.sql /tmp/extensions.sql" && eval ${command}
            command="${SUDO} /bin/cp /var/www/html/installation/sql/mysql/supports.sql /tmp/supports.sql" && eval ${command}
            command="${SUDO} /bin/sed -i \"s/#__/${PREFIX}_/g\" /tmp/base.sql" && eval ${command}
            command="${SUDO} /bin/sed -i \"s/#__/${PREFIX}_/g\" /tmp/extensions.sql" && eval ${command}
            command="${SUDO} /bin/sed -i \"s/#__/${PREFIX}_/g\" /tmp/supports.sql" && eval ${command}
        fi
    else 
        installationstatus="3"
    fi
    if ( [ -f /tmp/joomla.sql ] )
    then
        /usr/bin/mysql -f -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" < /tmp/joomla.sql
    else
        /usr/bin/mysql -f -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" < /tmp/base.sql
        /usr/bin/mysql -f -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" < /tmp/extensions.sql
        /usr/bin/mysql -f -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" < /tmp/supports.sql
    fi
  
    joomla_username="${BUILD_IDENTIFIER}-webmaster"
    joomla_password="`/bin/echo -n "${SERVER_USER}" | /usr/bin/md5sum | /usr/bin/awk '{print $1}'`"  
   
    /usr/bin/mysql -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" -e "INSERT INTO ${PREFIX}_users (id,name,username,email,password,registerdate,params,requirereset) values (42,'${joomla_username}','${joomla_username}','testxyz@test123.com','${joomla_password}','2020-04-20',1,1);"
    /usr/bin/mysql -A -u "${username}" -p"${password}" "${database}" --host="${host}" --port="${DB_PORT}" -e "INSERT INTO ${PREFIX}_user_usergroup_map values (42,8);"
   # command="${SUDO} /bin/rm /tmp/joomla.sql /tmp/base.sql /tmp/extensions.sql /tmp/supports.sql 2>/dev/null" && eval ${command}
fi


if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    installationstatus=""
    if ( [ -d /var/www/html/installation ] )
    then 
        if ( [ -f /var/www/html/installation/sql/postgresql/joomla.sql ] )
        then
            installationstatus="1"
            command="${SUDO} /bin/cp /var/www/html/installation/sql/postgresql/joomla.sql /tmp/joomla.sql" && eval ${command}
            command="${SUDO} /bin/sed -i \"s/#__/${PREFIX}_/g\" /tmp/joomla.sql" && eval ${command}
#            command="${SUDO} /bin/sed -i '1s/^/SET SESSION sql_require_primary_key=0;\n/' /tmp/joomla.sql" && eval ${command}
        else
            installationstatus="2"
#            command="${SUDO} /bin/sed -i '1s/^/SET SESSION sql_require_primary_key=0;\n/' /var/www/html/installation/sql/mysql/base.sql" && eval ${command}
#            command="${SUDO} /bin/sed -i '1s/^/SET SESSION sql_require_primary_key=0;\n/' /var/www/html/installation/sql/mysql/extensions.sql" && eval ${command}
#            command="${SUDO} /bin/sed -i '1s/^/SET SESSION sql_require_primary_key=0;\n/' /var/www/html/installation/sql/mysql/supports.sql" && eval ${command}
            command="${SUDO} /bin/cp /var/www/html/installation/sql/postgresql/base.sql /tmp/base.sql" && eval ${command}
            command="${SUDO} /bin/cp /var/www/html/installation/sql/postgresql/extensions.sql /tmp/extensions.sql" && eval ${command}
            command="${SUDO} /bin/cp /var/www/html/installation/sql/postgresql/supports.sql /tmp/supports.sql" && eval ${command}
            command="${SUDO} /bin/sed -i \"s/#__/${PREFIX}_/g\" /tmp/base.sql" && eval ${command}
            command="${SUDO} /bin/sed -i \"s/#__/${PREFIX}_/g\" /tmp/extensions.sql" && eval ${command}
            command="${SUDO} /bin/sed -i \"s/#__/${PREFIX}_/g\" /tmp/supports.sql" && eval ${command}
        fi
    else 
        installationstatus="3"
    fi

    command="${SUDO} ${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh < /tmp/base.sql" && eval ${command}
    command="${SUDO} ${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh < /tmp/extensions.sql" && eval ${command}
    command="${SUDO} ${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh < /tmp/supports.sql" && eval ${command}
    
   # SERVER_USER="`/bin/ls ${HOME}/.ssh/SERVERUSER:* | /usr/bin/awk -F':' '{print $NF}'`"
   # BUILD_IDENTIFIER="`/bin/ls ${HOME}/.ssh/BUILDIDENTIFIER:* | /usr/bin/awk -F':' '{print $NF}'`"
   # username="${BUILD_IDENTIFIER}-webmaster"
   # password="`/bin/echo ${SERVER_USER} | /usr/bin/openssl enc -base64`"
   # sqlcommand="INSERT INTO ${PREFIX}_users"
   # sqlcommand="${sqlcommand}"'(id,"\""name"\"","\""username"\"","\""email"\"","\""password"\"","\""registerDate"\"","\""params"\"","\""requireReset"\"") values (42,'\'''"${username}"''\'','\''webmaster'\'','\''testxyz@test123i4.com'\'','\'''"${password}"''\'','\''1980-01-01'\'',1,1);'

    joomla_username="${BUILD_IDENTIFIER}-webmaster"
    joomla_password="`/bin/echo -n "${SERVER_USER}" | /usr/bin/md5sum | /usr/bin/awk '{print $1}'`"  
    sqlcommand="INSERT INTO ${PREFIX}_users"
    sqlcommand="${sqlcommand}"'(id,"\""name"\"","\""username"\"","\""email"\"","\""password"\"","\""registerDate"\"","\""params"\"","\""requireReset"\"") values (42,'\''${joomla_username}'\'','\''${joomla_username}'\'','\''testxyz@test123i4.com'\'','\''${joomla_password}'\'','\''1980-01-01'\'',1,1);'
    command="${SUDO} ${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh \"${sqlcommand}\"" && eval ${command}

#    sqlcommand="INSERT INTO ${PREFIX}_users"
#    sqlcommand="${sqlcommand}"'(id,"\""name"\"","\""username"\"","\""email"\"","\""password"\"","\""registerDate"\"","\""params"\"","\""requireReset"\"") values (42,'\''webmaster'\'','\''webmaster'\'','\''testxyz@test123i4.com'\'','\''16d7a4fca7442dda3ad93c9a726597e4'\'','\''1980-01-01'\'',1,1);'
#    command="${SUDO} ${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh \"${sqlcommand}\"" && eval ${command}

    sqlcommand="INSERT INTO ${PREFIX}_user_usergroup_map values (42,8);"
    command="${SUDO} ${HOME}/providerscripts/utilities/ConnectToRemotePostgresDB.sh \"${sqlcommand}\"" && eval ${command}

    command="${SUDO} /bin/rm /tmp/joomla.sql /tmp/base.sql /tmp/extensions.sql /tmp/supports.sql 2>/dev/null" && eval ${command}
fi

if ( [ "${installationstatus}" = "3" ] )
then
     /bin/echo "NO INSTALLATION DIRECTORY FOUND FOR JOOMLA. CANNOT INSTALL..."
     /bin/echo "Press <enter> to acknowledge"
     read x
elif ( [ "${installationstatus}" = "2" ] )
then
     /bin/echo "Found installation material for joomla 4 - attempted to install joomla 4"
elif ( [ "${installationstatus}" = "1" ] )
then
    /bin/echo "Found installation material for joomla 3 - attempted to install joomla 3"
fi

if ( [ "${installationstatus}" = "2" ] || [ "${installationstatus}" = "1" ] )
then
    /bin/echo "The default credentials for your brand new joomla site are set to: Admin name: webmaster  Admin password: test1234"
    /bin/echo "Clearly, it is essential to change these to stop your site being compromised and they are just set as such to bootstrap your site building"
    /bin/echo "Press <enter> to acknowledge"
    read x
fi

#OK, if we get to here, we no longer need our default installation directory. It has served us well, so, we can nuke it
#command="${SUDO} /bin/rm -r /var/www/html/installation" && eval ${command}
command="${SUDO} /bin/mv /var/www/html/installation /tmp" && eval ${command}


