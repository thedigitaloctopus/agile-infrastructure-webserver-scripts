#!/bin/sh
#######################################################################################
# Description: If needs be, this script will install the necessary toolkit and generate
# a SSL certificate.
# Date: 16-11=16
# Author: Peter Winter
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
#################################################################################
#################################################################################
#set -x

BUILDOS="`/bin/ls ${HOME}/.ssh/BUILDOS:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "`/bin/ls ${HOME}/.ssh/SSLGENERATIONMETHOD:* | /usr/bin/awk -F':' '{print $NF}'`" = "AUTOMATIC" ] )
then
    if ( [ "`/bin/ls ${HOME}/.ssh/SSLGENERATIONSERVICE:* | /usr/bin/awk -F':' '{print $NF}'`" = "LETSENCRYPT" ] )
    then
        #If a certificate has been issued already in the past 30 minutes, forget it, it's too soon to even think about
        #generating another one
        if ( [ -f ${HOME}/config/SSLUPDATED ] )
        then
            exit
        fi

        #Setup our configuration
        DNS_USERNAME="`/bin/ls ${HOME}/.ssh/DNSUSERNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
        DNS_SECURITY_KEY="`/bin/ls ${HOME}/.ssh/DNSSECURITYKEY:* | /usr/bin/awk -F':' '{print $NF}'`"
        DNS_CHOICE="`/bin/ls ${HOME}/.ssh/DNSCHOICE:* | /usr/bin/awk -F':' '{print $NF}'`"
        WEBSITE_URL="`/bin/ls ${HOME}/.ssh/WEBSITEURL:* | /usr/bin/awk -F':' '{print $NF}'`"
        WEBSITE_NAME="`/bin/ls ${HOME}/.ssh/WEBSITEDISPLAYNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
        SERVER_USER_PASSWORD="`/bin/ls ${HOME}/.ssh/SERVERUSERPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"

        #Install GO for use installing the new cert
        cd ${HOME}

        if ( [ ! -d /usr/local/go ] )
        then
            ${HOME}/installscripts/InstallGo.sh ${BUILDOS}
        fi

        export GOROOT=/usr/local/go
        export GOPATH=$HOME
        export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

        if ( [ ! -f /usr/bin/lego ] )
        then
            ${HOME}/installscripts/InstallLego.sh ${BUILDOS}
        fi

        DOMAIN_URL="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/awk -F'.' '{$1="";print}' | /bin/sed 's/^ //' | /bin/sed 's/ /./g'`"

        if ( [ ! -d ${HOME}/.lego/certificates ] )
        then
            /bin/mkdir -p ${HOME}/.lego/certificates
        fi

        if ( [ ! -d ${HOME}/.lego/accounts ] )
        then
            /bin/cp -r ${HOME}/config/ssl/accounts ${HOME}/.lego
        fi

        /bin/cp ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/.lego/certificates/${WEBSITE_URL}.crt
        /bin/cp ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ${HOME}/.lego/certificates/${WEBSITE_URL}.key
        /bin/cp ${HOME}/ssl/live/${WEBSITE_URL}/${WEBSITE_URL}.json ${HOME}/.lego/certificates/${WEBSITE_URL}.json


        if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
        then
            /bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E CLOUDFLARE_EMAIL="${DNS_USERNAME}" CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --accept-tos run

            #/bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E CLOUDFLARE_EMAIL="${DNS_USERNAME}" CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}" GCE_PROJECT="${WEBSITE_NAME}" GCE_DOMAIN="${DOMAIN_URL}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --server=https://acme-v02.api.letsencrypt.org/directory --accept-tos run
            if ( [ "$?" = "0" ] )
            then
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATED" "Successfully generated a new SSL Certificate"
            else
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATION FAILED" "Failed to generate a new SSL certificate, you might want to look into why..."
            fi
        fi

        if ( [ "${DNS_CHOICE}" = "rackspace" ] )
        then
            DNS_EMAIL="`/bin/ls ${HOME}/.ssh/DNSEMAILADDRESS:* | /usr/bin/awk -F':' '{print $NF}'`"
            /bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E RACKSPACE_USER="${DNS_USERNAME}" RACKSPACE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_EMAIL}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --accept-tos run

            #/bin/echo ${SERVER_USER_PASSWORD}  | /usr/bin/sudo -S -E RACKSPACE_USER="${DNS_USERNAME}" RACKSPACE_API_KEY="${DNS_SECURITY_KEY}" GCE_PROJECT="${WEBSITE_NAME}" GCE_DOMAIN="${DOMAIN_URL}" /usr/bin/lego --email="${DNS_EMAIL}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --server=https://acme-v02.api.letsencrypt.org/directory --accept-tos run


            if ( [ "$?" = "0" ] )
            then
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATED" "Successfully generated a new SSL Certificate"
            else
                ${HOME}/providerscripts/email/SendEmail.sh "NEW SSL CERT GENERATION FAILED" "Failed to generate a new SSL certificate, you might want to look into why..."
            fi
        fi

        if ( [ ! -d ${HOME}/ssl/live/${WEBSITE_URL} ] )
        then
            /bin/mkdir -p ${HOME}/ssl/live/${WEBSITE_URL}
        fi

        #Copy our new certificate to the live directory for usage by the webserver.
        if ( [ -f ${HOME}/.lego/certificates/${WEBSITE_URL}.crt ] && [ -f ${HOME}/.lego/certificates/${WEBSITE_URL}.key ] && [ -f ${HOME}/.lego/certificates/${WEBSITE_URL}.json ] )
        then
            /bin/cat ${HOME}/.lego/certificates/${WEBSITE_URL}.crt ${HOME}/.lego/certificates/${WEBSITE_URL}.key > ${HOME}/ssl/live/${WEBSITE_URL}/ssl
            /bin/cp ${HOME}/ssl/live/${WEBSITE_URL}/ssl ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
            /bin/mv ${HOME}/ssl/live/${WEBSITE_URL}/ssl ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
            /bin/cp ${HOME}/.lego/certificates/${WEBSITE_URL}.json ${HOME}/ssl/live/${WEBSITE_URL}/${WEBSITE_URL}.json
            /bin/cp ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem ${HOME}/config/ssl/privkey.pem
            /bin/cp ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/config/ssl/fullchain.pem
            /bin/cp ${HOME}/ssl/live/${WEBSITE_URL}/${WEBSITE_URL}.json ${HOME}/config/ssl/${WEBSITE_URL}.json
            /bin/chmod 700 ${HOME}/config/ssl/fullchain.pem ${HOME}/config/ssl/privkey.pem ${HOME}/config/ssl/${WEBSITE_URL}.json
            /bin/chmod 700 ${HOME}/ssl/live/${WEBSITE_URL}/${WEBSITE_URL}.json ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
            /bin/touch ${HOME}/config/SSLUPDATED
        fi

        ${HOME}/providerscripts/webserver/ReloadWebserver.sh

    fi
elif ( [ "`/bin/ls ${HOME}/.ssh/SSLGENERATIONMETHOD:* | /usr/bin/awk -F':' '{print $NF}'`" = "MANUAL" ] )
then
:
fi
