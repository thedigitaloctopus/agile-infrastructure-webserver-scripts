#!/bin/sh
######################################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This is the script which builds a webserver
######################################################################################################
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
#set -x

#If there is a problem with building a webserver, you can uncomment the set -x command and debug output will be
#presented on the screen as your webserver is built

#HOMEDIRFORROOT="`/bin/echo ${HOME} | /bin/sed 's/\///g' | /bin/sed 's/home//g'`"
#HOMEDIRFORROOT="`/bin/ls /home | /bin/grep '^X'`"
#/usr/bin/touch /root/.ssh/HOMEDIRFORROOT:${HOMEDIRFORROOT}
#HOMEDIR="/home/`/bin/ls /root/.ssh/HOMEDIRFORROOT:* | /usr/bin/awk -F':' '{print $NF}'`"
#export HOME="${HOMEDIR}"

USER_HOME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"
export HOME="/home/${USER_HOME}"
export HOMEDIR=${HOME}
/bin/echo "${HOMEDIR}" > /home/homedir.dat

#First thing is to tighten up permissions in case there's any wronguns. 
/bin/chmod -R 750 ${HOME}/autoscaler ${HOME}/cron ${HOME}/installscripts ${HOME}/providerscripts ${HOME}/security

#Setup operational directories if needed
if ( [ ! -d ${HOME}/logs ] )
then
    /bin/mkdir ${HOME}/logs
fi

OUT_FILE="webserver-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${OUT_FILE}
ERR_FILE="webserver-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${ERR_FILE}

#Check parameters
###############################################################################################################################
#Remeber if you make any changes to the parameters to this script, it is called in two places, on the Build Client during the
#build process and also on the autoscaler from the BuildWebserver script.
#Both places will need updating to reflect the changes that you make to the parameters
###############################################################################################################################
if ( [ "$1" = "" ]  || [ "$2" = "" ] )
then
    /bin/echo "${0} Usage: ./ws.sh <build archive> <server user>" >> ${HOME}/logs/WEBSERVER_BUILD.log
    exit
fi

BUILD_ARCHIVE_CHOICE="$1"
SERVER_USER="$2"

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} `/bin/date`: Building a new webserver" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} `/bin/date`: Setting up the build parameters" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log

#Load the environment into memory for convenience

${HOME}/providerscripts/utilities/StoreConfigValue.sh "BUILDARCHIVECHOICE" "${BUILD_ARCHIVE_CHOICE}"

CLOUDHOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'CLOUDHOST'`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
ALGORITHM="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'ALGORITHM'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
DATASTORE_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"
WEBSERVER_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSERVERCHOICE'`"
INFRASTRUCTURE_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPROVIDER'`"
INFRASTRUCTURE_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYUSERNAME'`"
INFRASTRUCTURE_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPASSWORD'`"
INFRASTRUCTURE_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'`"

GIT_EMAIL_ADDRESS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'GITEMAILADDRESS'`"
APPLICATION_LANGUAGE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONLANGUAGE'`"
SERVER_TIMEZONE_CONTINENT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
SSH_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SSH_PORT'`"

#Non standard environment setup process
GIT_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'GITUSER' | /bin/sed 's/#/ /g'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
BASELINE_SOURCECODE_REPOSITORY="`/bin/grep 'APPLICATIONBASELINESOURCECODEREPOSITORY' ${HOME}/.ssh/webserver_configuration_settings.dat | /usr/bin/cut -d':' -f 2-`"

#Record what everything has actually been set to in case there is a problem...
/bin/echo "CLOUDHOST:${CLOUDHOST}" > ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "BUILD_IDENTIFIER:${BUILD_IDENTIFIER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "ALGORITHM:${ALGORITHM}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "WEBSITE_URL:${WEBSITE_URL}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "DATASTORE_PROVIDER:${DATASTORE_PROVIDER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "WEBSERVER_CHOICE:${WEBSERVER_CHOICE}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_PROVIDER:${INFRASTRUCTURE_REPOSITORY_PROVIDER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_USERNAME:${INFRASTRUCTURE_REPOSITORY_USERNAME}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_PASSWORD:${INFRASTRUCTURE_REPOSITORY_PASSWORD}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "INFRASTRUCTURE_REPOSITORY_OWNER:${INFRASTRUCTURE_REPOSITORY_OWNER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_REPOSITORY_PROVIDER:${APPLICATION_REPOSITORY_PROVIDER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_REPOSITORY_OWNER:${APPLICATION_REPOSITORY_OWNER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_REPOSITORY_USERNAME:${APPLICATION_REPOSITORY_USERNAME}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_REPOSITORY_PASSWORD:${APPLICATION_REPOSITORY_PASSWORD}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_IDENTIFIER:${APPLICATION_IDENTIFIER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "GIT_EMAIL_ADDRESS:${GIT_EMAIL_ADDRESS}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "APPLICATION_LANGUAGE:${APPLICATION_LANGUAGE}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "SERVER_TIMEZONE_CONTINENT:${SERVER_TIMEZONE_CONTINENT}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "SERVER_TIMEZONE_CITY:${SERVER_TIMEZONE_CITY}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "BUILDOS:${BUILDOS}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "SSH_PORT:${SSH_PORT}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "GIT_USER:${GIT_USER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "WEBSITE_NAME:${WEBSITE_NAME}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "ROOT_DOMAIN:${ROOT_DOMAIN}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "WEBSITE_DISPLAY_NAME:${WEBSITE_DISPLAY_NAME}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "WEBSITE_DISPLAY_NAME_UPPER:${WEBSITE_DISPLAY_NAME_UPPER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "WEBSITE_DISPLAY_NAME_LOWER:${WEBSITE_DISPLAY_NAME_LOWER}" >> ${HOME}/logs/InitialBuildEnvironment.log
/bin/echo "BASELINE_SOURCECODE_REPOSITORY:${BASELINE_SOURCECODE_REPOSITORY}" >> ${HOME}/logs/InitialBuildEnvironment.log

#Set up more operational directories
if ( [ ! -d ${HOME}/.ssh ] )
then
    /bin/mkdir ${HOME}/.ssh
fi

if ( [ ! -d ${HOME}/providerscripts ] )
then
    /bin/mkdir ${HOME}/providerscripts
    /bin/chmod 700 ${HOME}/providerscripts
fi

if ( [ ! -d ${HOME}/applicationscripts ] )
then
    /bin/mkdir ${HOME}/applicationscripts
    /bin/chmod 700 ${HOME}/applicationscripts
fi

if ( [ ! -d ${HOME}/cpuaggregator ] )
then
    /bin/mkdir ${HOME}/cpuaggregator
    /bin/chmod 700 ${HOME}/cpuaggregator
fi

if ( [ ! -d ${HOME}/runtime ] )
then
    /bin/mkdir ${HOME}/runtime
    /bin/chmod 700 ${HOME}/runtime
fi

if ( [ ! -d ${HOME}/.cache ] )
then
    /bin/mkdir ${HOME}/.cache
    /bin/chown ${SERVER_USER}.${SERVER_USER} ${HOME}/.cache
    /bin/chmod 700 ${HOME}/.cache
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} `/bin/date`: Setting the hostname" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
#Set the hostname of the machine
/bin/echo "${WEBSITE_NAME}WS" > /etc/hostname
/bin/hostname -F /etc/hostname

if ( [ "${BUILDOS}" = "debian" ] )
then
    /bin/sed -i "/127.0.0.1/ s/$/ ${WEBSITE_NAME}WS/" /etc/cloud/templates/hosts.debian.tmpl
    /bin/sed -i '1 i\127.0.0.1        localhost' /etc/cloud/templates/hosts.debian.tmpl

    if ( [ "`/bin/cat /etc/hosts | /bin/grep 127.0.1.1 | /bin/grep "${WEBSITE_NAME}"`" = "" ] )
    then
        /bin/sed -i "s/127.0.1.1/127.0.1.1 ${WEBSITE_NAME}WSX/g" /etc/hosts
        /bin/sed -i "s/X.*//" /etc/hosts
    fi

    /bin/sed -i "0,/127.0.0.1/s/127.0.0.1/127.0.0.1 ${WEBSITE_NAME}WS/" /etc/hosts
else
    /usr/bin/hostnamectl set-hostname ${WEBSITE_NAME}WS
fi


#Safety in case kernel panics
/bin/echo "vm.panic_on_oom=1
kernel.panic=10" >> /etc/sysctl.conf

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} `/bin/date`: Updating the software from the repositories" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/rm /var/lib/dpkg/lock
/bin/rm /var/cache/apt/archives/lock

/bin/echo "${0} `/bin/date`: Installing software" >> ${HOME}/logs/WEBSERVER_BUILD.log
#Install the software packages that we need

${HOME}/installscripts/Update.sh ${BUILDOS}
${HOME}/installscripts/InstallCurl.sh ${BUILDOS}
${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS}
${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS}
${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS}
${HOME}/installscripts/InstallJQ.sh ${BUILDOS}
${HOME}/installscripts/InstallUnzip.sh ${BUILDOS}
${HOME}/installscripts/InstallSSHPass.sh ${BUILDOS}
${HOME}/installscripts/InstallSysStat.sh ${BUILDOS}
${HOME}/installscripts/InstallUFW.sh ${BUILDOS}
${HOME}/installscripts/InstallSSHFS.sh ${BUILDOS}
${HOME}/installscripts/InstallS3FS.sh ${BUILDOS}
${HOME}/installscripts/InstallRsync.sh ${BUILDOS}

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh ENABLEEFS:1`" = "1" ] )
then
    ${HOME}/installscripts/InstallNFS.sh ${BUILDOS}
fi

${HOME}/providerscripts/utilities/InstallMonitoringGear.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0}: Setting timezone" >> ${HOME}/logs/MonitoringLog.dat
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
#Set the time on the machine
/usr/bin/timedatectl set-timezone ${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}
${HOME}/providerscripts/utilities/StoreConfigValue.sh "SERVERTIMEZONECONTINENT" "${SERVER_TIMEZONE_CONTINENT}"
${HOME}/providerscripts/utilities/StoreConfigValue.sh "SERVERTIMEZONECITY" "${SERVER_TIMEZONE_CITY}"
export TZ=":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}"

#Do rudimentary checks that the software has been installed correctly
if ( [ -f /usr/bin/curl ] && [ -f /usr/bin/sendemail ] && [ -f /usr/bin/jq ] && [ -f /usr/bin/unzip ] )
then
    /bin/echo "${0} `/bin/date` : It looks like all the required software has installed correctly." >> ${HOME}/logs/WEBSERVER_BUILD.log
else
    /bin/echo "${0} `/bin/date` : It looks like all the required software hasn't installed correctly." >> ${HOME}/logs/WEBSERVER_BUILD.log
    exit
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Installing cloudhost tools" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log

#Install the tools for our particular cloudhost provider
. ${HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh

cd ${HOME}

/bin/echo "${0} `/bin/date`: Installing GIT" >> ${HOME}/logs/WEBSERVER_BUILD.log
#Install and configure the git repository management toolkit
/usr/bin/git init
/usr/bin/git config --global user.name "${GIT_USER}"
/usr/bin/git config --global user.email ${GIT_EMAIL_ADDRESS}

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} `/bin/date`: Pulling scripts from infrastructure repository with credentials parameters:" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Provider: ${INFRASTRUCTURE_REPOSITORY_PROVIDER} " >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Provider: ${INFRASTRUCTURE_REPOSITORY_USERNAME} " >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Provider: ${INFRASTRUCTURE_REPOSITORY_OWNER} " >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log

${HOME}/bootstrap/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-webserver-scripts > /dev/null 2>&1

/usr/bin/find ${HOME} -type d -print0 | xargs -0 chmod 0755 # for directories
/usr/bin/find ${HOME} -type f -print0 | xargs -0 chmod 0755 # for files

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Installing Datastore tools" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
. ${HOME}/providerscripts/datastore/InstallDatastoreTools.sh

# Install the language engine for whatever language your application is written in
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Installing Application Language: ${APPLICATION_LANGUAGE}" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
${HOME}/providerscripts/webserver/InstallApplicationLanguage.sh "${APPLICATION_LANGUAGE}"

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Installing Webserver: ${WEBSERVER_CHOICE} for ${WEBSITE_NAME} at: ${WEBSITE_URL}" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "`${HOME}/providerscripts/utilities/GetIP.sh` ${WEBSITE_NAME}WS" >> /etc/hosts
${HOME}/providerscripts/webserver/InstallWebserver.sh "${WEBSERVER_CHOICE}" "${WEBSITE_NAME}" "${WEBSITE_URL}"

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Modifying sshd settings and restarting sshd" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log

cd ${HOME}
#Set the port for ssh to use
/bin/sed -i "s/22/${SSH_PORT}/g" /etc/ssh/sshd_config
/bin/sed -i 's/^#Port/Port/' /etc/ssh/sshd_config
/bin/sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
/bin/sed -i 's/.*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

#Make sure that client connections to sshd are long lasting
if ( [ "`/bin/cat /etc/ssh/sshd_config | /bin/grep 'ClientAliveInterval 200' 2>/dev/null`" = "" ] )
then
    /bin/echo "
ClientAliveInterval 200
    ClientAliveCountMax 10" >> /etc/ssh/sshd_config
fi

/usr/sbin/service sshd restart

/bin/sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf
#SERVER_USER_PASSWORD="`/bin/ls /home/${SERVER_USER}/.ssh/SERVERUSERPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"

#Install the application
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Initialising the git version control system" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log

if ( [ ! -d /var/www/html ] )
then
    /bin/mkdir -p /var/www/html > /dev/null 2>&1
fi
cd /var/www/html
/bin/rm -r /var/www/html/* > /dev/null 2>&1
/bin/rm -r /var/www/html/.git > /dev/null 2>&1
/usr/bin/git init

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Installing the custom application" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log

. ${HOME}/applicationscripts/InstallApplication.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Applying application specific customisations" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
. ${HOME}/applicationscripts/ApplyApplicationBranding.sh
. ${HOME}/applicationscripts/CustomiseApplication.sh
${HOME}/providerscripts/application/customise/AdjustApplicationInstallationByApplication.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Adjusting webroot permissions and ownerships" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/chown -R www-data.www-data /var/www/* > /dev/null 2>&1
/usr/bin/find /var/www -type d -exec chmod 755 {} \;
/usr/bin/find /var/www -type f -exec chmod 644 {} \;

cd ${HOME}

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Find out what type of application we are installing, for example, Joomla, Wordpress, Drupal or Moodle" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
${HOME}/providerscripts/application/processing/DetermineApplicationType.sh > /dev/null 2>&1

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Install Database client for accessing the database from the command line easily" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
. ${HOME}/providerscripts/utilities/InstallDatabaseClient.sh

#Set our status as a new build
/bin/touch ${HOME}/runtime/NEWLYBUILT

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Initialise the crontab" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log

. ${HOME}/providerscripts/utilities/InitialiseCron.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Getting IP address:his call is necessary as it primes the networking interface for some providers." >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
${HOME}/providerscripts/utilities/GetIP.sh

#Finally shutdown or reboot, this reinitialises everything making sure the webserver is ready for use
/bin/rm -r ${HOME}/bootstrap

/usr/bin/touch ${HOME}/runtime/WEBSERVER_READY

#Have to switch off IPV6 because sometimes ufw was giving errors with it enabled.
/bin/sed -i "s/IPV6=yes/IPV6=no/g" /etc/default/ufw

/bin/echo "${SERVER_USER} ALL= NOPASSWD:/usr/bin/rsync" >> /etc/sudoers

/bin/chown -R ${SERVER_USER}.${SERVER_USER} ${HOME}
#Switch logging off on the firewall
/usr/sbin/ufw logging off

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Switching on firewall now that we have got everything installed" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/usr/sbin/ufw default allow incoming
/usr/sbin/ufw default allow outgoing
/usr/sbin/ufw --force enable

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} Sending notification email that a webserver has been built" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log

${HOME}/providerscripts/email/SendEmail.sh "A WEBSERVER HAS BEEN SUCCESSFULLY BUILT" "A Webserver has been successfully built and primed as is rebooting ready for use"

/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} `/bin/date`: Rebooting post install....." >> ${HOME}/logs/WEBSERVER_BUILD.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/WEBSERVER_BUILD.log
/sbin/shutdown -r now
