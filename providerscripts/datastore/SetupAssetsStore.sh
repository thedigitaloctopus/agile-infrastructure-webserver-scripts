#!/bin/sh
####################################################################################
# Description: This script mounts a bucket from a cloud based datastore and uses it
# as a shared config directory to pass configuration settings around between machines
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

#if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PERSISTASSETSTOCLOUD:1`" = "1" ] && [ ! -f ${HOME}/runtime/S3BUCKETSET ] )
#then
#    domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
#    /usr/bin/s3cmd mb s3://${domainspecifier}
#   # /bin/touch ${HOME}/.ssh/ASSETSBUCKET:${domainspecifier}
#    ${HOME}/providerscripts/utilities/StoreConfigValue.sh "ASSETSBUCKET" "${domainspecifier}"
#    /bin/touch ${HOME}/runtime/S3BUCKETSET
#    exit
#elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PERSISTASSETSTOCLOUD:0`" = "1" ] )
#then
#    exit
#fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PERSISTASSETSTOCLOUD:0`" = "1" ] )
then
    exit
fi

trap cleanup 0 1 2 3 6 9 14 15

cleanup()
{
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
    exit
}

#directories_to_mount="`/bin/ls ${HOME}/.ssh/DIRECTORIESTOMOUNT:* | /bin/sed 's/:config//g'`"
directories_to_mount="`${HOME}/providerscripts/utilities/ExtractConfigValues.sh 'DIRECTORIESTOMOUNT' 'stripped' | /bin/sed 's/:config//g'`"
directories=""
for directory in ${directories_to_mount}
do
    #processed_directories="${processed_directories}`/bin/echo "${directory} " | /bin/sed 's/.*DIRECTORIESTOMOUNT://g' | /bin/sed 's/:/ /g' | /bin/sed 's/\./\//g'`"
    processed_directories="${processed_directories}`/bin/echo "${directory} " | /bin/sed 's/\./\//g'`"
done

applicationassetdirs="${processed_directories}"
applicationassetbuckets="`/bin/echo ${applicationassetdirs} | /bin/sed 's/\//\-/g'`"

for directory_to_mount in ${applicationassetdirs}
do
    if ( [ "`/bin/mount | /bin/grep /var/www/html/${directory_to_mount}`" = "" ] )
    then
        /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
    fi
    
    # Sometimes S3FS freezes, at least, I have seen it happen, so, I put this check in which places a monitoring file which won't get deleted
    # if the attempt to list from s3 - ls ${HOME}/config freezed the last time around. This is an emergency situation, so, we shutdown the webserver
    # so that the S3FS system can recover. The server will be offline for 10s of seconds in this case whilst it reboots. 
    # If anyone knows of a solution for shared directories which would suit this toolkit better, your help would be appreciated. 

    if ( [ "`/usr/bin/find ${HOME}/runtime/S3FS-TESTER -type f`" != "" ] )
    then
        /bin/rm ${HOME}/runtime/S3FS-TESTER-${directory_to_mount}
        /usr/sbin/shutdown -r now
    fi

    /bin/touch ${HOME}/runtime/S3FS-TESTER-"`/bin/echo ${directory_to_mount} | /bin/sed 's/\///g'`"
    /bin/ls /var/www/html/${directory_to_mount}
    /bin/rm ${HOME}/runtime/S3FS-TESTER-"`/bin/echo ${directory_to_mount} | /bin/sed 's/\///g'`"

    if ( [ "`/bin/ls /var/www/html/${directory_to_mount} 2>&1 | /bin/grep "Transport endpoint is not connected"`" != "" ] )
    then
        /bin/umount -f /var/www/html/${directory_to_mount}
    fi
    
    # I found that S3FS has memory creep meaning that it slowly uses up more and more memory to deal with this in as least hacky was as possible
    # I check when S3FS is using more than 15% memory and unmount it and remounting it straight away. This will release the memory it was using
    # until the next time its at 15% when this process will be repeated again

   # if ( [ "`/usr/bin/ps aux --sort=-%mem | /usr/bin/head | /bin/grep s3fs | /bin/grep ${directory_to_mount} | /usr/bin/awk '{print $4}'`" -gt "15" ] )
   # then
   #     /bin/sleep `/usr/bin/shuf -i 1-60 -n 1`
   #     /bin/umount -f /var/www/html/${directory_to_mount}
   # fi
done

if ( [ -f ${HOME}/runtime/SYNCINGASSETSTODATASTORE ] )
then
    exit
fi

s3fs_gid="`/usr/bin/id -g www-data`"
s3fs_uid="`/usr/bin/id -u www-data`"

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"

for assetbucket in ${applicationassetbuckets}
do
    assetbuckets="${assetbuckets} `/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-${assetbucket}"
done

if ( [ "${DATASTORE_CHOICE}" = "amazonS3" ] )
then
    export AWSACCESSKEYID=`/bin/grep 'access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    endpoint="`/bin/cat ~/.s3cfg | /bin/grep host_base | /usr/bin/awk '{print $NF}'`"

    #Depending on the application, sometimes it can take a while to initially sync the assets, so, we don't want to mount
    #whilst syncing is going on if we call it again from cron, mid-sync, then we will find this flag set and exit
    /bin/touch ${HOME}/runtime/SYNCINGASSETSTODATASTORE

    loop="1"
    for assetbucket in ${assetbuckets}
    do
        asset_directory="`/bin/echo ${applicationassetdirs} | /usr/bin/cut -d " " -f ${loop}`"
        if ( [ "`/bin/mount | /bin/grep "/var/www/html/${asset_directory}"`" = "" ] )
        then
            if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh ENABLEEFS:1`" = "1" ] )
            then
                aws_region="`/bin/grep region ${HOME}/.aws/config | /usr/bin/awk '{print $NF}'`"
                /bin/mkdir ~/.aws 2>/dev/null
                /bin/cp ${HOME}/.aws/* ~/.aws 2>/dev/null
                /bin/chmod 500 ~/.aws/*
           
               export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.aws/credentials | /usr/bin/awk '{print $NF}'`
               export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.aws/credentials | /usr/bin/awk '{print $NF}'`

                /usr/bin/aws efs describe-file-systems | /usr/bin/jq '.FileSystems[] | .CreationToken + " " + .FileSystemId' | /bin/sed 's/\"//g' | /bin/grep -v "\-config" | while read identifier
                do
                    if ( [ "`/bin/echo ${identifier} | /bin/grep ${assetbucket}`" != "" ] )
                    then
                        id="`/bin/echo ${identifier} | /usr/bin/awk '{print $NF}'`"
                        efsmounttarget="`/usr/bin/aws efs describe-mount-targets --file-system-id ${id} | /usr/bin/jq '.MountTargets[].IpAddress' | /bin/sed 's/"//g'`"
                                                
                        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ]  )
                        then
                            /bin/mkdir -p /tmp/${asset_directory}
                            /bin/mv /var/www/html/${asset_directory}/* /tmp/${asset_directory}
                        else
                            /bin/mkdir -p /var/www/html/${asset_directory}
                        fi
                        
                        /bin/mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efsmounttarget}:/   /var/www/html/${asset_directory}
                        
                        /bin/chown www-data.www-data /var/www/html/${asset_directory}
                        
                        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ]  )
                        then  
                            /bin/mv /tmp/${asset_directory}/* /var/www/html/${asset_directory}
                        fi
                    fi
                done
            else
                /usr/bin/s3cmd mb s3://${assetbucket}
                /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}
                /bin/chmod 777 /var/www/html/${asset_directory}
                /bin/chown www-data.www-data /var/www/html/${asset_directory}
                /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,max_stat_cache_size=10000,stat_cache_expire=20,multireq_max=3 -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
            fi
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi

if ( [ "${DATASTORE_CHOICE}" = "digitalocean" ] )
then
    export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    endpoint="`/bin/grep host_base ~/.s3cfg | /usr/bin/awk '{print $NF}'`"

    #Depending on the application, sometimes it can take a while to initially sync the assets, so, we don't want to mount
    #whilst syncing is going on if we call it again from cron, mid-sync, then we will find this flag set and exit
    /bin/touch ${HOME}/runtime/SYNCINGASSETSTODATASTORE

    loop="1"
    for assetbucket in ${assetbuckets}
    do
        asset_directory="`/bin/echo ${applicationassetdirs} | /usr/bin/cut -d " " -f ${loop}`"
        if ( [ "`/bin/mount | /bin/grep "/var/www/html/${asset_directory}"`" = "" ] )
        then
            /usr/bin/s3cmd mb s3://${assetbucket}
            /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}                       
            /bin/mkdir -p /var/www/html/${asset_directory}
            /bin/chmod 777 /var/www/html/${asset_directory}
            /bin/chown www-data.www-data /var/www/html/${asset_directory}
            /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,max_stat_cache_size=10000,stat_cache_expire=20,multireq_max=3 -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi

if ( [ "${DATASTORE_CHOICE}" = "exoscale" ] )
then
    export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    endpoint="`/bin/grep host_base ~/.s3cfg | /usr/bin/awk '{print $NF}'`"

    #Depending on the application, sometimes it can take a while to initially sync the assets, so, we don't want to mount
    #whilst syncing is going on if we call it again from cron, mid-sync, then we will find this flag set and exit
    /bin/touch ${HOME}/runtime/SYNCINGASSETSTODATASTORE

    loop="1"
    for assetbucket in ${assetbuckets}
    do
        asset_directory="`/bin/echo ${applicationassetdirs} | /usr/bin/cut -d " " -f ${loop}`"
        if ( [ "`/bin/mount | /bin/grep "/var/www/html/${asset_directory}"`" = "" ] )
        then
            /usr/bin/s3cmd mb s3://${assetbucket}
            /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}
            /bin/mkdir -p /var/www/html/${asset_directory}
            /bin/chmod 777 /var/www/html/${asset_directory}
            /bin/chown www-data.www-data /var/www/html/${asset_directory}
            /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,max_stat_cache_size=10000,stat_cache_expire=20,multireq_max=3 -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi

if ( [ "${DATASTORE_CHOICE}" = "linode" ] )
then
    export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    endpoint="`/bin/grep host_base ~/.s3cfg | /usr/bin/awk '{print $NF}'`"

    #Depending on the application, sometimes it can take a while to initially sync the assets, so, we don't want to mount
    #whilst syncing is going on if we call it again from cron, mid-sync, then we will find this flag set and exit
    /bin/touch ${HOME}/runtime/SYNCINGASSETSTODATASTORE

    loop="1"
    for assetbucket in ${assetbuckets}
    do
        asset_directory="`/bin/echo ${applicationassetdirs} | /usr/bin/cut -d " " -f ${loop}`"
        if ( [ "`/bin/mount | /bin/grep "/var/www/html/${asset_directory}"`" = "" ] )
        then
            /usr/bin/s3cmd mb s3://${assetbucket}
            /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}
            /bin/mkdir -p /var/www/html/${asset_directory}
            /bin/chmod 777 /var/www/html/${asset_directory}
            /bin/chown www-data.www-data /var/www/html/${asset_directory}
            /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,max_stat_cache_size=10000,stat_cache_expire=20,multireq_max=3 -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi

if ( [ "${DATASTORE_CHOICE}" = "vultr" ] )
then
    export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    endpoint="`/bin/grep host_base ~/.s3cfg | /usr/bin/awk '{print $NF}'`"

    #Depending on the application, sometimes it can take a while to initially sync the assets, so, we don't want to mount
    #whilst syncing is going on if we call it again from cron, mid-sync, then we will find this flag set and exit
    /bin/touch ${HOME}/runtime/SYNCINGASSETSTODATASTORE

    loop="1"
    for assetbucket in ${assetbuckets}
    do
        asset_directory="`/bin/echo ${applicationassetdirs} | /usr/bin/cut -d " " -f ${loop}`"
        if ( [ "`/bin/mount | /bin/grep "/var/www/html/${asset_directory}"`" = "" ] )
        then
            /usr/bin/s3cmd mb s3://${assetbucket}
            /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}
            /bin/mkdir -p /var/www/html/${asset_directory}
            /bin/chmod 777 /var/www/html/${asset_directory}
            /bin/chown www-data.www-data /var/www/html/${asset_directory}
            /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,max_stat_cache_size=10000,stat_cache_expire=20,multireq_max=3 -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi
