#!/bin/sh

#set -x
export HOME=`/bin/cat /home/homedir.dat`
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
configbucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
configbucket="${configbucket}-config"

if ( [ "`/usr/bin/s3cmd ls s3://${configbucket}/$1`" = "" ] )
then
    /bin/echo "0"
else
    /bin/echo "1"
fi