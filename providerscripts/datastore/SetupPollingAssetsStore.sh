#!/bin/sh
####################################################################################
# Description: This script will move files out of their webserver directories and into
# s3 buckets which can then be distributed using a CDN at an application level
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
#set -x

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

directories_to_mount="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:config//g'`"
directories=""
for directory in ${directories_to_mount}
do
    processed_directories="${processed_directories}`/bin/echo "${directory} " | /bin/sed 's/\./\//g'`"
done

applicationassetdirs="${processed_directories}"
applicationassetbuckets="`/bin/echo ${applicationassetdirs} | /bin/sed 's/\//\-/g'`"

for assetbucket in ${applicationassetbuckets}
do
    assetbuckets="${assetbuckets} `/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-${assetbucket}"
done

for assetbucket in ${assetbuckets}
do
   if ( [ "`/usr/bin/s3cmd ls s3://${assetbucket}`" = "" ] )
   then
       /usr/bin/s3cmd mb s3://${assetbucket}
    fi
done

count="1"

for applicationassetdir in ${applicationassetdirs}
do
    currentbucket="`/bin/echo ${assetbuckets} | /usr/bin/cut -d " " -f ${count}`"
    applicationassetdir="/var/www/html/${applicationassetdir}"
    directory="`/bin/echo ${applicationassetdir} | /usr/bin/awk -F'/' '{print $NF}'`"
    echo ${applicationassetdir}
    files="`/usr/bin/find ${applicationassetdir}`"
    if ( [ "${files}" != "" ] )
    then
        for file in "`/usr/bin/find ${applicationassetdir} -type f`"
        do
            bucketfile="`/bin/echo ${file} | /bin/sed "s/.*${directory}//g"`"
            /usr/bin/s3cmd put ${file} s3://${currentbucket}${bucketfile}
            /bin/rm ${file}
        done
        count="`/usr/bin/expr ${count} + 1`"
    fi
    
done
