#!/bin/sh

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
    files="`/usr/bin/find ${applicationassetdir} -type f`"
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
