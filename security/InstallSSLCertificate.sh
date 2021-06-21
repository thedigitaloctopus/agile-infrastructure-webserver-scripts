#!/bin/bash
################################################################################
# Author: Peter Winter
# Date  : 07/07/2016
# Description: This script tests the current SSL certificate. If it is out of date
# or approaching it's expiry date, a new certificate is generated and replaces it.
# This check is also done on the build client, where a copy of the SSL certificate
# but is necessary here, it is run daily from cron, in case the infrastructure is
# left running for extended periods meaning there is no new builds and therefore no
# opportunity to check for the validity of the certificate.
##################################################################################
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
###################################################################################
###################################################################################
#set -x

exec >>${HOME}/logs/SSL_CERT_INSTALLATION.log
exec 2>&1

#Setup configuration parameters
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
DNS_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DNSUSERNAME'`"
DNS_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DNSCHOICE'`"
DNS_SECURITY_KEY="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DNSSECURITYKEY'`"
SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"

BUILD_TIME="${1}"

LIFE="0"
RENEW="1"

#Get the values we need from our current certificate
if ( 	[ "`/bin/ls ${HOME}/ssl/live/*/fullchain.pem 2>/dev/null`" != "" ] &&
[ "`/bin/ls ${HOME}/ssl/live/*/privkey.pem 2>/dev/null`" != "" ] )
then
    # Get the current date as seconds since epoch.
    NOW=$(date +%s)
    # Get the expiry date of our certificate.
    EXPIRE=$(openssl x509 -in ${HOME}/ssl/live/*/fullchain.pem -noout -enddate)
    # Trim the unecessary text at the start of the string.
    EXPIRE="`/bin/echo ${EXPIRE} | /usr/bin/awk -F'=' '{print $2}'`"
    # Convert the expiry date to seconds since epoch.
    EXPIRE=$(date --date="$EXPIRE" +%s)
    # Calculate the time left until the certificate expires.
    LIFE=$((EXPIRE-NOW))
    # The remaining life on our certificate below which we should renew (7 days).
    RENEW=604800
fi

# Check if the certificate has less life remaining than we want.
if ( [ "${LIFE}" -lt "${RENEW}" ] )
then
    cd ${HOME}
    . ${HOME}/security/ObtainSSLCertificate.sh
else
    #If we are here, then the certificate we had was valid and we didn't need to generate a new one this time around
    /bin/echo "Valid"
fi
