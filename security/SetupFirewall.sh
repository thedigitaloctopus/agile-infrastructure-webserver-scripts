#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Setup the firewall
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
##################################################################################
##################################################################################
#set -x #THIS MUST NOT BE SWITCHED ON DURING NORMAL USE, SCRIPT BREAK
##################################################################################

if ( [ ! -d ${HOME}/logs/firewall ] )
then
    /bin/mkdir -p ${HOME}/logs/firewall
fi

#This stream manipulation is necessary for correct functioning, please do not remove it
exec >${HOME}/logs/firewall/FIREWALL_CONFIGURATION.log
exec 2>&1
##################################################################################

#if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
#then
#    exit
#fi

. ${HOME}/providerscripts/utilities/SetupInfrastructureIPs.sh

SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SSH_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SSHPORT'`"

# Allow the building client to connect to the webserver
/bin/sleep 5

if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${BUILD_CLIENT_IP} | /bin/grep ALLOW`" = "" ] )
then
    /usr/sbin/ufw default deny incoming
    /usr/sbin/ufw default allow outgoing
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${BUILD_CLIENT_IP} to any port ${SSH_PORT}
    ${HOME}/providerscripts/utilities/ConnectToAutoscaler.sh "${HOME}/providerscripts/server/UpdateNativeFirewall.sh" ${BUILD_CLIENT_IP} ${SSH_PORT}
fi

#NEW_BUILD_CLIENT_IP="`/bin/ls /tmp/BUILDCLIENTIP/* | /usr/bin/awk -F'/' '{print $NF}'`"
#if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${NEW_BUILD_CLIENT_IP} | /bin/grep ALLOW`" = "" ] )
#then
#    /usr/sbin/ufw default deny incoming
#    /usr/sbin/ufw default allow outgoing
#    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${NEW_BUILD_CLIENT_IP} to any port ${SSH_PORT}
#    /bin/sleep 5
#fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PRODUCTION:1`" = "1" ] )
then
   # autoscalerip="`/bin/ls ${HOME}/config/autoscalerip`"
   # publicautoscalerip="`/bin/ls ${HOME}/config/autoscalerpublicip`"
    
    
    for autoscalerip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh autoscalerip/*`
    do 
           if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${autoscalerip} | /bin/grep ${SSH_PORT} | /bin/grep ALLOW`" = "" ] )
           then
              /bin/sleep 2
              /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${autoscalerip} to any port ${SSH_PORT}
           fi
           if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${autoscalerip} | /bin/grep 443 | /bin/grep ALLOW`" = "" ] )
           then
              /bin/sleep 2
              /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${autoscalerip} to any port 443
           fi   
           if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${autoscalerip} | /bin/grep 80 | /bin/grep ALLOW`" = "" ] )
           then
              /bin/sleep 2
              /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${autoscalerip} to any port 80           
           fi
        
           ${HOME}/providerscripts/utilities/ConnectToAutoscaler.sh "${HOME}/providerscripts/server/UpdateNativeFirewall.sh" ${autoscalerip}
           if ( [ -f /etc/apache2/mods-available/evasive.conf ] )
           then
               /bin/sed -i "/.*\/IfModule.*/i DOSWhitelist ${autoscalerip}" /etc/apache2/mods-available/evasive.conf
           fi
    done
    
    for publicautoscalerip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh autoscalerpublicip/*`
    do

        if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${publicautoscalerip} | /bin/grep ALLOW`" = "" ] )
        then
           if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${publicautoscalerip} | /bin/grep ${SSH_PORT} | /bin/grep ALLOW`" = "" ] )
           then
              /bin/sleep 2
              /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${publicautoscalerip} to any port ${SSH_PORT}
           fi
           if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${publicautoscalerip} | /bin/grep 443 | /bin/grep ALLOW`" = "" ] )
           then
              /bin/sleep 2
              /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${publicautoscalerip} to any port 443
           fi   
           if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${publicautoscalerip} | /bin/grep 80 | /bin/grep ALLOW`" = "" ] )
           then
              /bin/sleep 2
              /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${publicautoscalerip} to any port 80           
           fi
            ${HOME}/providerscripts/utilities/ConnectToAutoscaler.sh "${HOME}/providerscripts/server/UpdateNativeFirewall.sh" ${publicautoscalerip}
           if ( [ -f /etc/apache2/mods-available/evasive.conf ] )
           then
               /bin/sed -i "/.*\/IfModule.*/i DOSWhitelist ${publicautoscalerip}" /etc/apache2/mods-available/evasive.conf
           fi
        fi
    done
fi


for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverips/*`
do
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 2
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
        ${HOME}/providerscripts/utilities/ConnectToAutoscaler.sh "${HOME}/providerscripts/server/UpdateNativeFirewall.sh" ${ip} ${SSH_PORT}
    fi
done

for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh webserverpublicips/*`
do
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 2
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
        ${HOME}/providerscripts/utilities/ConnectToAutoscaler.sh "${HOME}/providerscripts/server/UpdateNativeFirewall.sh" ${ip} ${SSH_PORT}
    fi
done

for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databaseip/*`
do
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 2
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
        ${HOME}/providerscripts/utilities/ConnectToAutoscaler.sh "${HOME}/providerscripts/server/UpdateNativeFirewall.sh" ${ip} ${SSH_PORT}
    fi
done

for ip in `${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh databasepublicip/*`
do
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 2
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
        ${HOME}/providerscripts/utilities/ConnectToAutoscaler.sh "${HOME}/providerscripts/server/UpdateNativeFirewall.sh" ${ip} ${SSH_PORT}
    fi
done


. ${HOME}/security/SetupDNSFirewall.sh

/bin/sleep 2

#if ( [ "`/bin/cat ${HOME}/logs/FIREWALL_CONFIGURATION.log | /bin/grep 'Chain already exists.'`" != "" ] )
#then
#    /sbin/iptables -F
#    /sbin/iptables -X
#    /sbin/iptables -Z
#    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw --force reset
#    /bin/cp /dev/null ${HOME}/logs/FIREWALL_CONFIGURATION.log
#fi

/usr/sbin/ufw -f enable
