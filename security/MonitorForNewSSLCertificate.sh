#!/bin/sh
#############################################################################
# Description: It is important to remember that there can be 1..n webservers
# running and yet they will all want the same SSL certificate.
# If one webserver detects, 'hey shit, the SSL cert is getting low on it's validity'
# then it will generate a new one. We don't want all the other webservers to go off
# and generate their own certificates when one has already setup a fresh new one, so,
# instead, we copy the fresh certificate to our shared directory and then each webserver
# can detect it and make it's own copy of it and then start to use it. It is a rare
# event that a cert will be renewed and we check for it at night, the webserver is
# then reloaded to pick up the new certificate.
# Date: 16/11/2017
# Author: Peter Winter
#############################################################################
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

if ( [ "`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SSLGENERATIONMETHOD'`" = "AUTOMATIC" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SSLGENERATIONSERVICE'`" = "LETSENCRYPT" ] )
    then
        WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

        if ( [ -f ${HOME}/config/ssl/fullchain.pem ] && [ -f ${HOME}/config/ssl/privkey.pem ] && [ -f ${HOME}/config/ssl/${WEBSITE_URL}.json ] && [ -f ${HOME}/config/SSLUPDATED ] )
        then
            ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/fullchain.pem /tmp/fullchain.pem
            ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/privkey.pem /tmp/privkey.pem
            ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ssl/${WEBSITE_URL}.json /tmp/${WEBSITE_URL}.json
            
            if ( [ "`/usr/bin/diff /tmp/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem`" != "" ] ||
                 [ "`/usr/bin/diff /tmp/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem`" != "" ] ||
                 [ "`/usr/bin/diff /tmp/${WEBSITE_URL}.json ${HOME}/ssl/live/${WEBSITE_URL}/${WEBSITE_URL}.json`" != "" ] )
            then
                /bin/mv ${HOME}/.ssh/privkey.pem ${HOME}/.ssh/privkey.pem.previous.`/bin/date | /bin/sed 's/ //g'`
                /bin/mv ${HOME}/.ssh/fullchain.pem ${HOME}/.ssh/fullchain.pem.previous.`/bin/date | /bin/sed 's/ //g'`
                /bin/mv ${HOME}/.ssh/${WEBSITE_URL}.json ${HOME}/.ssh/${WEBSITE_URL}.json.previous.`/bin/date | /bin/sed 's/ //g'`
                /bin/cp /tmp/fullchain.pem ${HOME}/.ssh/fullchain.pem
                /bin/cp /tmp/privkey.pem ${HOME}/.ssh/privkey.pem
                /bin/cp /tmp/${WEBSITE_URL}.json ${HOME}/.ssh/${WEBSITE_URL}.json
                /bin/cp /tmp/fullchain.pem ${HOME}/ssl/live/${WEBSITE_URL}/fullchain.pem
                /bin/cp /tmp/privkey.pem ${HOME}/ssl/live/${WEBSITE_URL}/privkey.pem
                /bin/cp /tmp/${WEBSITE_URL}.json ${HOME}/ssl/live/${WEBSITE_URL}/${WEBSITE_URL}.json
                ${HOME}/providerscripts/webserver/ReloadWebserver.sh
            fi

            if ( [ "`/usr/bin/diff /tmp/fullchain.pem ${HOME}/.ssh/fullchain.pem`" != "" ] ||
                 [ "`/usr/bin/diff /tmp/privkey.pem ${HOME}/.ssh/privkey.pem`" != "" ] ||
                 [ "`/usr/bin/diff /tmp/${WEBSITE_URL}.json ${HOME}/.ssh/${WEBSITE_URL}.json`" != "" ] )
            then
                /bin/mv ${HOME}/.ssh/privkey.pem ${HOME}/.ssh/privkey.pem.previous.`/bin/date | /bin/sed 's/ //g'`
                /bin/mv ${HOME}/.ssh/fullchain.pem ${HOME}/.ssh/fullchain.pem.previous.`/bin/date | /bin/sed 's/ //g'`
                /bin/mv ${HOME}/.ssh/${WEBSITE_URL}.json ${HOME}/.ssh/${WEBSITE_URL}.json.previous.`/bin/date | /bin/sed 's/ //g'`
                /bin/mv /tmp/fullchain.pem ${HOME}/.ssh/fullchain.pem
                /bin/mv /tmp/privkey.pem ${HOME}/.ssh/privkey.pem
                /bin/mv /tmp/${WEBSITE_URL}.json ${HOME}/.ssh/${WEBSITE_URL}.json
            fi
        fi
    fi
fi
