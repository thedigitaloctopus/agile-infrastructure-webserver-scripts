#!/bin/sh

WEBSITE_URL="ok.nuocial.org.uk"
configbucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
configbucket="${configbucket}-config"

/usr/bin/s3cmd ls s3://${configbucket}/$1 | /usr/bin/awk -F'/' '{print $NF}' | /bin/sed '/^$/d'
