#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: This will check the build style for an application
#######################################################################################
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
########################################################################################
########################################################################################
#set -x

if ( [ "${1}" = "" ] )
then
    /bin/echo "Sorry, you need to tell me which configuration file I am updating, for example, 'joomla_configuration'"
    exit
fi

if ( [ ! -f ${HOME}/runtime/${1}.php.new ] )
then
    /bin/echo "Need a file called: ${HOME}/runtime/${1}.php.new"
    exit
fi

ip="`${HOME}/providerscripts/utilities/GetIP.sh`"

/bin/cp ${HOME}/runtime/${1}.php.new ${HOME}/runtime/${1}.php
/bin/cp ${HOME}/runtime/${1}.php.new ${HOME}/config/${1}.php
/bin/echo " " >> ${HOME}/config/${1}.php
/bin/rm ${HOME}/runtime/${1}.php.new

/bin/echo "Processing, please do not interrupt...."
/bin/echo "Counting down...."

count="0"
while ( [ "${count}" -lt "10" ] )
do   
    /bin/echo "`/usr/bin/expr 10 - ${count}`"
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh GLOBAL_CONFIG_UPDATE.${ip} 
    /bin/sleep 10
    count="`/usr/bin/expr ${count} + 1`"
done

/bin/echo "##############################################################################"
/bin/echo "Your application's new configuration should have been pushed to all webservers"
/bin/echo "##############################################################################"
