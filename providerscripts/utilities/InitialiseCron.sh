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

SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"
HOMEDIR="`/bin/cat /home/homedir.dat`"

/bin/echo "${0} `/bin/date`: Installing cron" >> ${HOME}/logs/WEBSERVER_BUILD.log
#These scripts run every minute
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/webserver/CheckWebserverIsUp.sh ${WEBSERVER_CHOICE}" >> /var/spool/cron/crontabs/${SERVER_USER}
#/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/cron/ConfigureDBAccessCron.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO}  ${HOME}/providerscripts/application/configuration/ConfigureDBAccessByApplication.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO}  ${HOME}/cron/InitialiseVirginApplicationCron.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO}  ${HOME}/providerscripts/application/configuration/InstallConfigurationByApplication.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO}  ${HOME}/providerscripts/application/configuration/VerifyConfigurationByApplication.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO}  ${HOME}/providerscripts/utilities/AcknowledgeBuildCompletion.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && /bin/sleep 30 && ${SUDO} ${HOME}/providerscripts/utilities/UpdateIP.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO}  ${HOME}/security/MonitorForNewSSLCertificate.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
#Clean up any stale locks from the cron process
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO} /usr/bin/find ${HOME}/runtime -name *lock* -type f -mmin +35 -delete" >> /var/spool/cron/crontabs/${SERVER_USER}
#We have a flag to tell us if one of the webservers has updated the SSL certificate. If so, other webservers don't try.
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO} /usr/bin/find ${HOME}/config/SSLUPDATED -type f -mmin +30 -delete" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/cron/PurgeDodgyMountsCron.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * /bin/sleep 25 && export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/application/configuration/ShareApplicationConfiguration.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/datastore/SetupConfig.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/datastore/SetupAssetsStore.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/cron/SetupFirewallFromCron.sh" >> /var/spool/cron/crontabs/${SERVER_USER}

#if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS-secured`" = "1" ] )
#then
#    /bin/echo "*/1 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/SetupSSHTunnel.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
#    /bin/echo "@reboot /bin/rm ${SUDO}  ${HOME}/runtime/SSHTUNNELCONFIGURED" >> /var/spool/cron/crontabs/${SERVER_USER}
#fi

#These scripts run every set interval
/bin/echo "*/5 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/security/MonitorFirewall.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/5 * * * * export HOME="${HOMEDIR}" &&  /bin/sleep 20 && ${SUDO} ${HOME}/cron/SyncToWebrootTunnelFromCron.sh && /bin/sleep 60 && ${SUDO} ${HOME}/cron/SyncFromWebrootTunnelFromCron.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/5 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/AuditForLowCPUStates.sh 10" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/5 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/AuditForLowMemoryStates.sh 90" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "*/5 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/AuditForLowDiskStates.sh 100000" >> /var/spool/cron/crontabs/${SERVER_USER}

#These scripts run at set times these will make a backup of our webroot to git and also to our datastore if super safe

/bin/echo "30 5 * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/EnforcePermissions.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "2 * * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/cron/BackupFromCron.sh 'HOURLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "8 2 * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/cron/BackupFromCron.sh 'DAILY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "8 3 * * 7 export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/cron/BackupFromCron.sh 'WEEKLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "8 4 1 * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/cron/BackupFromCron.sh 'MONTHLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "8 5 1 Jan,Mar,May,Jul,Sep,Nov * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/cron/BackupFromCron.sh 'BIMONTHLY' ${BUILD_IDENTIFIER}" >> /var/spool/cron/crontabs/${SERVER_USER}

/bin/echo "30 02 * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/RegulateSyncProcessReset.sh" >> /var/spool/cron/crontabs/${SERVER_USER}

#On a daily basis, check if the ssl certificate has expired. Once it has expired, we will try and issue a new one
/bin/echo "00 4 * * * export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/cron/InstallSSLCertificateFromCron.sh" >> /var/spool/cron/crontabs/${SERVER_USER}

#These scripts run at every predefined interval


/bin/echo "@daily export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/PerformSoftwareUpdate.sh" >> /var/spool/cron/crontabs/${SERVER_USER}

#/bin/echo "@reboot export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/application/email/ActivateSMTPByApplication.sh \"${WEBSITE_DISPLAY_NAME}\"" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/webserver/RestartWebserver.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/application/configuration/InstallConfigurationByApplication.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/CleanupAtReboot.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/SetHostname.sh" >> /var/spool/cron/crontabs/${SERVER_USER}

/bin/echo "@reboot export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/datastore/SetupConfig.sh reboot" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "@reboot /bin/sleep 600 && export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/security/KnickersUp.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "@reboot /bin/sleep 20 && export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/UpdateWebroot.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/EnforcePermissions.sh" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${SUDO} /usr/bin/find ${HOME}/runtime -name *lock* -type f -delete" >> /var/spool/cron/crontabs/${SERVER_USER}
/bin/echo "@reboot export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/GetIP.sh" >> /var/spool/cron/crontabs/${SERVER_USER}

SERVER_TIMEZONE_CONTINENT="`export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`export HOME="${HOMEDIR}" && ${SUDO} ${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
/bin/echo "@reboot export TZ=\":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}\"" >> /var/spool/cron/crontabs/${SERVER_USER}


####If a specific application needs additions to crontab, you can place them here:

#restart cron
/usr/bin/crontab /var/spool/cron/crontabs/${SERVER_USER}
