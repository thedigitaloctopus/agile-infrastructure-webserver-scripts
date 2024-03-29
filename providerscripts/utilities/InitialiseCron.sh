#!/bin/sh
######################################################################################
# Description: This script will initialise your crontab for you
# Author: Peter Winter
# Date: 28/01/2017
######################################################################################
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
######################################################################################
######################################################################################
#set -x

/bin/echo "${0} `/bin/date`: Installing cron" >> ${HOME}/logs/WEBSERVER_BUILD.log
#These scripts run every minute
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/webserver/CheckWebserverIsUp.sh ${WEBSERVER_CHOICE}" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/configuration/ConfigureDBAccessByApplication.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/configuration/InitialiseVirginInstallByApplication.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/configuration/InstallConfigurationByApplication.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/AcknowledgeBuildCompletion.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/sleep 30 && ${HOME}/providerscripts/utilities/UpdateIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/security/MonitorForNewSSLCertificate.sh" >> /var/spool/cron/crontabs/root

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
then
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/webserver/configuration/AllowGatewayBypass.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/security/GatewayGuardian.sh" >> /var/spool/cron/crontabs/root
    /bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/security/GatewayGuardian.sh" >> /var/spool/cron/crontabs/root
fi

#Clean up any stale locks from the cron process
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /usr/bin/find ${HOME}/runtime -name *lock* -type f -mmin +35 -delete" >> /var/spool/cron/crontabs/root
#We have a flag to tell us if one of the webservers has updated the SSL certificate. If so, other webservers don't try.
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/cron/PurgeDodgyMountsCron.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/configuration/ShareApplicationConfiguration.sh" >> /var/spool/cron/crontabs/root

if ( [ "`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PERSISTASSETSTOCLOUD'`" = "1" ] )
then
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/datastore/SetupAssetsStore.sh" >> /var/spool/cron/crontabs/root
fi

if ( [ "`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PERSISTASSETSTOCLOUD'`" = "2" ] )
then
    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/datastore/SetupPollingAssetsStore.sh" >> /var/spool/cron/crontabs/root
fi

/bin/echo "*/1 * * * * export HOME=${HOMEDIR} && ${HOME}/providerscripts/datastore/ObtainBuildClientIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/cron/SetupFirewallFromCron.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/MarkedForShutdown.sh" >> /var/spool/cron/crontabs/root


#These scripts run every set interval
/bin/echo "*/5 * * * * export HOME="${HOMEDIR}" && ${HOME}/security/MonitorFirewall.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/5 * * * * export HOME="${HOMEDIR}" &&  /bin/sleep 20 && ${HOME}/cron/SyncToWebrootTunnelFromCron.sh && /bin/sleep 60 && ${HOME}/cron/SyncFromWebrootTunnelFromCron.sh" >> /var/spool/cron/crontabs/root

#These scripts run at set times these will make a backup of our webroot to git and also to our datastore if super safe
#Time based backups are not taken for virgin CMS installs. Instead, make a baseline if you want to save a copy of your work and work it out from there once your application is ready

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "0" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "0" ] ) 
then
   /bin/echo "30 5 * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/EnforcePermissions.sh" >> /var/spool/cron/crontabs/root
   /bin/echo "2 * * * * export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'HOURLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root
   /bin/echo "8 2 * * * export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'DAILY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root
   /bin/echo "8 3 * * 7 export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'WEEKLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root
   /bin/echo "8 4 1 * * export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'MONTHLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root
   /bin/echo "8 5 1 Jan,Mar,May,Jul,Sep,Nov * export HOME="${HOMEDIR}" && ${HOME}/cron/BackupFromCron.sh 'BIMONTHLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/root
fi
/bin/echo "30 02 * * * export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/RegulateSyncProcessReset.sh" >> /var/spool/cron/crontabs/root

#On a daily basis, check if the ssl certificate has expired. Once it has expired, we will try and issue a new one
/bin/echo "00 4 * * * export HOME="${HOMEDIR}" && ${HOME}/cron/InstallSSLCertificateFromCron.sh" >> /var/spool/cron/crontabs/root

#These scripts run at every predefined interval


/bin/echo "@daily export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/PerformSoftwareUpdate.sh" >> /var/spool/cron/crontabs/root

#/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh \"${WEBSITE_DISPLAY_NAME}\"" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/webserver/RestartWebserver.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/application/configuration/InstallConfigurationByApplication.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/CleanupAtReboot.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/SetHostname.sh" >> /var/spool/cron/crontabs/root

/bin/echo "@reboot /bin/sleep 600 && export HOME="${HOMEDIR}" && ${HOME}/security/KnickersUp.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot /bin/sleep 20 && export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/UpdateWebroot.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/EnforcePermissions.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && /usr/bin/find ${HOME}/runtime -name *lock* -type f -delete" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/GetIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME=${HOMEDIR} && ${HOME}/providerscripts/utilities/UpdateInfrastructure.sh" >>/var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/MonitorCron.sh" >> /var/spool/cron/crontabs/root

SERVER_TIMEZONE_CONTINENT="`export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`export HOME="${HOMEDIR}" && ${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
/bin/echo "@reboot export TZ=\":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}\"" >> /var/spool/cron/crontabs/root


####If a specific application needs additions to crontab, you can place them here:

#restart cron
/usr/bin/crontab -u root /var/spool/cron/crontabs/root

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    /bin/echo "*/1 * * * * /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null" > /var/spool/cron/crontabs/www-data
fi

#restart cron
/usr/bin/crontab -u www-data /var/spool/cron/crontabs/www-data
