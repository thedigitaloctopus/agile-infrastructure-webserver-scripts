#!/bin/sh
####################################################################################
# Description: This script checks to see if the server is alive. It's a simple process,
# it connects to the database and checks that a response is returned. This way, we know
# that we are alive and well.
# Date: 16/11/2016
# Author: Peter Winter
###################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:None`" = "1" ] )
then
    /bin/echo "ALIVE"
else

    DB_N="`/bin/sed '1q;d' ${HOME}/config/credentials/shit`"
    DB_P="`/bin/sed '2q;d' ${HOME}/config/credentials/shit`"
    DB_U="`/bin/sed '3q;d' ${HOME}/config/credentials/shit`"

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
    then
        SERVER_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
    else
        SERVER_NAME="`/bin/ls ${HOME}/config/databaseip | /usr/bin/head -1`"
    fi

    DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        if ( [ -f /usr/bin/php ] && ( [ "`/usr/bin/php ${HOME}/providerscripts/utilities/dbalive/mysqlalive.php ${SERVER_NAME} ${DB_U} ${DB_P} ${DB_N} ${DB_PORT} | /bin/sed 's/ //g'`" != "ALIVE" ] ) )
        then
            #This is a nasty networking hack. I was getting some problems with no route to host errors when using the private
            #networking. In most places I work around this by using the public ip address of the machine rather than the
            #private one, but it's a bit awkward here to use the public ip address because of the db configuration, so, instead
            #I give these commands a chance to see if it resolves the issue for us
            if ( [ "${SERVER_NAME}" != "" ] )
            then
                machineaddress="`/usr/sbin/arp -a ${SERVER_NAME} | /usr/bin/awk '{print $4}'`"
                /usr/sbin/arp -s ${SERVER_NAME} ${machineaddress}
            fi
        else
            /bin/echo "ALIVE"
        fi
    else
        if ( [ -f /usr/bin/mysql ] )
        then
            if ( [ "`/usr/bin/mysql -u ${DB_U} -p${DB_P} -h ${SERVER_NAME} -P ${DB_PORT} ${DB_N} -e "show tables"`" != "" ] )
            then
                /bin/echo "ALIVE"
            fi
        fi
    fi

    if ( [ -f /usr/bin/php ] && ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] ) )
    then
        if ( [ "`/usr/bin/php ${HOME}/providerscripts/utilities/dbalive/postgresalive.php ${SERVER_NAME} ${DB_U} ${DB_P} ${DB_N} ${DB_PORT} | /bin/sed 's/ //g'`" != "ALIVE" ] )
        then
            #This is a nasty networking hack. I was getting some problems with no route to host errors when using the private
            #networking. In most places I work around this by using the public ip address of the machine rather than the
            #private one, but it's a bit awkward here to use the public ip address because of the db configuration, so, instead
            #I give these commands a chance to see if it resolves the issue for us
            machineaddress="`/usr/sbin/arp -a ${SERVER_NAME} | /usr/bin/awk '{print $4}'`"
            /usr/sbin/arp -s ${SERVER_NAME} ${machineaddress}
        else
            /bin/echo "ALIVE"
        fi
    else
        if ( [ -f /usr/bin/psql ] )
        then
            export PGPASSWORD=${DB_P}
            if ( [ "`/usr/bin/psql -U ${DB_U} -h ${SERVER_NAME} -p ${DB_PORT} ${DB_N} -c "select exists ( select 1 from information_schema.tables );"` | /bin/grep 'exists'" != "" ] )
            then
                /bin/echo "ALIVE"
            fi
        fi
    fi
fi

