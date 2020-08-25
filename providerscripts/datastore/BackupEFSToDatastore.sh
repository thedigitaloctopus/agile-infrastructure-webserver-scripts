#!/bin/sh
####################################################################################
# Description: This script replicates the EFS filesystems to s3 buckets
# Author: Peter Winter
# Date :  9/4/2016
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
####################################################################################
####################################################################################
set -x

directories_to_mount="`/bin/ls ${HOME}/.ssh/DIRECTORIESTOMOUNT:* | /bin/sed 's/:config//g'`"
directories=""
for directory in ${directories_to_mount}
do
    processed_directories="${processed_directories}`/bin/echo "${directory} " | /bin/sed 's/.*DIRECTORIESTOMOUNT://g' | /bin/sed 's/:/ /g' | /bin/sed 's/\./\//g'`"
done

applicationassetdirs="${processed_directories}"
applicationassetbuckets="`/bin/echo ${applicationassetdirs} | /bin/sed 's/\//\-/g'`"

BUILDOS="`/bin/ls ${HOME}/.ssh/BUILDOS:* | /usr/bin/awk -F':' '{print $NF}'`"
DATASTORE_PROVIDER="`/bin/ls ${HOME}/.ssh/DATASTORECHOICE:* | /usr/bin/awk -F':' '{print $NF}'`"
WEBSITE_URL="`/bin/ls ${HOME}/.ssh/WEBSITEURL:* | /usr/bin/awk -F':' '{print $NF}'`"
for assetbucket in ${applicationassetbuckets}
do
    assetbuckets="${assetbuckets} `/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-${assetbucket}"
done

if ( [ "${DATASTORE_PROVIDER}" = "amazonS3" ] )
then
    export AWSACCESSKEYID=`/bin/cat ~/.s3cfg | /bin/grep 'access_key' | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/cat ~/.s3cfg | /bin/grep 'secret_key' | /usr/bin/awk '{print $NF}'`

    loop="1"
    for assetbucket in ${assetbuckets}
    do
        asset_directory="`/bin/echo ${applicationassetdirs} | /usr/bin/cut -d " " -f ${loop}`"
        if ( [ "`/bin/mount | /bin/grep "/var/www/html/${asset_directory}"`" != "" ] )
        then
            if ( [ -f ${HOME}/.ssh/ENABLEEFS:1 ] )
            then
                /usr/bin/aws efs describe-file-systems | /usr/bin/jq '.FileSystems[] | .CreationToken + " " + .FileSystemId' | /bin/sed 's/\"//g' | while read identifier
                do
                    if ( [ "`/bin/echo ${identifier} | /bin/grep ${assetbucket}`" != "" ] )
                    then
                        id="`/bin/echo ${identifier} | /usr/bin/awk '{print $NF}'`"
                        /usr/bin/s3cmd mb s3://${assetbucket}-${id}
                        /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}-${id}
                    fi
                done
            fi
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
fi       

if ( [ "${DATASTORE_PROVIDER}" = "digitalocean" ] )
then
        :
fi

if ( [ "${DATASTORE_PROVIDER}" = "exoscale" ] )
then
        :
fi

if ( [ "${DATASTORE_PROVIDER}" = "linode" ] )
then
        :
fi

if ( [ "${DATASTORE_PROVIDER}" = "vultr" ] )
then
        :
fi
