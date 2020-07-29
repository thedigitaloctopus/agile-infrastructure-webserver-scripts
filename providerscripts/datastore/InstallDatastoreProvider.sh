#!/bin/sh
#############################################################################################
# Description: This script will install the necessary tools for the chosen datastore provider
# Author: Peter Winter
# Date: 04/01/2017
#############################################################################################
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

SERVER_USER="`/bin/ls /home | /bin/grep "X*X"`"

datastore_provider="${1}"
if ( [ "${datastore_provider}" = "amazonS3" ] || [ "${datastore_provider}" = "digitalocean" ] || [ "${datastore_provider}" = "exoscale" ] ||  [ "${datastore_provider}" = "linode" ] || [ "${datastore_provider}" = "vultr" ]  )
then
    if ( [ ! -f /usr/bin/s3cmd ] )
    then
        /home/${SERVER_USER}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD'
    fi
    if ( [ ! -f ~/.s3cfg ] )
    then
        /bin/echo "You need to configure your datastore tools. You can get your access keys by going to your AWS account at aws.amazon.com and following the instructions"
        /usr/bin/s3cmd --configure
    fi
fi
