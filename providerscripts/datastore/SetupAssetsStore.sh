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

if ( [ -f ${HOME}/.ssh/PERSISTASSETSTOCLOUD:0 ] && [ ! -f ${HOME}/runtime/S3BUCKETSET ] )
then
    domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
    /usr/bin/s3cmd mb s3://${domainspecifier}
    /bin/touch ${HOME}/.ssh/ASSETSBUCKET:${domainspecifier}
    /bin/touch ${HOME}/runtime/S3BUCKETSET
    exit
else
    exit
fi

trap cleanup 0 1 2 3 6 9 14 15

cleanup()
{
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
    exit
}

directories_to_mount="`/bin/ls ${HOME}/.ssh/DIRECTORIESTOMOUNT:* | /bin/sed 's/:config//g'`"
directories=""
for directory in ${directories_to_mount}
do
    processed_directories="${processed_directories}`/bin/echo "${directory} " | /bin/sed 's/.*DIRECTORIESTOMOUNT://g' | /bin/sed 's/:/ /g' | /bin/sed 's/\./\//g'`"
done

applicationassetdirs="${processed_directories}"
applicationassetbuckets="`/bin/echo ${applicationassetdirs} | /bin/sed 's/\//\-/g'`"

for directory_to_mount in ${applicationassetdirs}
do
    if ( [ "`/bin/mount | /bin/grep /var/www/html/${directory_to_mount}`" = "" ] )
    then
        /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
    fi

    if ( [ "`/bin/ls /var/www/html/${directory_to_mount} 2>&1 | /bin/grep "Transport endpoint is not connected"`" != "" ] )
    then
        /bin/umount -f /var/www/html/${directory_to_mount}
    fi
done

if ( [ -f ${HOME}/runtime/SYNCINGASSETSTODATASTORE ] )
then
    exit
fi

if ( [ ! -d ${HOME}/datastore_cache ] )
then
    /bin/mkdir -p ${HOME}/datastore_cache
fi

s3fs_gid="`/usr/bin/id -g www-data`"
s3fs_uid="`/usr/bin/id -u www-data`"

BUILDOS="`/bin/ls ${HOME}/.ssh/BUILDOS:* | /usr/bin/awk -F':' '{print $NF}'`"
DATASTORE_PROVIDER="`/bin/ls ${HOME}/.ssh/DATASTORECHOICE:* | /usr/bin/awk -F':' '{print $NF}'`"
for assetbucket in ${applicationassetbuckets}
do
    assetbuckets="${assetbuckets} `/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-${assetbucket}"
done

if ( [ "${DATASTORE_PROVIDER}" = "amazonS3" ] )
then
    export AWSACCESSKEYID=`/bin/cat ~/.s3cfg | /bin/grep 'access_key' | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/cat ~/.s3cfg | /bin/grep 'secret_key' | /usr/bin/awk '{print $NF}'`
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
            if ( [ -f ${HOME}/.ssh/ENABLEEFS:1 ] )
            then
                aws_region="`/bin/cat ${HOME}/.aws/config | /bin/grep region | /usr/bin/awk '{print $NF}'`"
                /bin/mkdir ~/.aws 2>/dev/null
                /bin/cp ${HOME}/.aws/* ~/.aws 2>/dev/null
                /bin/chmod 500 ~/.aws/*
           
               export AWSACCESSKEYID=`/bin/cat ~/.aws/credentials | /bin/grep '^access_key' | /usr/bin/awk '{print $NF}'`
               export AWSSECRETACCESSKEY=`/bin/cat ~/.aws/credentials | /bin/grep 'secret_key' | /usr/bin/awk '{print $NF}'`

                /usr/bin/aws efs describe-file-systems | /usr/bin/jq '.FileSystems[] | .CreationToken + " " + .FileSystemId' | /bin/sed 's/\"//g' | while read identifier
                do
                    if ( [ "`/bin/echo ${identifier} | /bin/grep ${assetbucket}`" != "" ] )
                    then
                        id="`/bin/echo ${identifier} | /usr/bin/awk '{print $NF}'`"
                        efsmounttarget="`/usr/bin/aws efs describe-mount-targets --file-system-id ${id} | /usr/bin/jq '.MountTargets[].IpAddress' | /bin/sed 's/"//g'`"
                        
                        if ( [ -f ${HOME}/.ssh/BUILDARCHIVECHOICE:baseline ] || [ -f ${HOME}/.ssh/BUILDARCHIVECHOICE:virgin ] )
                        then
                            /bin/mkdir -p /tmp/${asset_directory}
                            /bin/mv /var/www/html/${asset_directory}/* /tmp/${asset_directory}
                        else
                            /bin/mkdir -p /var/www/html/${asset_directory}
                        fi
                        
                        /bin/mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efsmounttarget}:/   /var/www/html/${asset_directory}
                        
                        /bin/chown www-data.www-data /var/www/html/${asset_directory}
                        
                        if ( [ -f ${HOME}/.ssh/BUILDARCHIVECHOICE:baseline ] || [ -f ${HOME}/.ssh/BUILDARCHIVECHOICE:virgin ] )
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
                /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,sigv2 -o use_cache=${HOME}/datastore_cache -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
            fi
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi

if ( [ "${DATASTORE_PROVIDER}" = "digitalocean" ] )
then
    export AWSACCESSKEYID=`/bin/cat ~/.s3cfg | /bin/grep '^access_key' | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/cat ~/.s3cfg | /bin/grep 'secret_key' | /usr/bin/awk '{print $NF}'`
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
            /usr/bin/s3cmd mb s3://${assetbucket}
            /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}                       
            /bin/mkdir -p /var/www/html/${asset_directory}
            /bin/chmod 777 /var/www/html/${asset_directory}
            /bin/chown www-data.www-data /var/www/html/${asset_directory}
            /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,sigv2 -o use_cache=${HOME}/datastore_cache -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi

if ( [ "${DATASTORE_PROVIDER}" = "exoscale" ] )
then
    export AWSACCESSKEYID=`/bin/cat ~/.s3cfg | /bin/grep '^access_key' | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/cat ~/.s3cfg | /bin/grep 'secret_key' | /usr/bin/awk '{print $NF}'`
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
            /usr/bin/s3cmd mb s3://${assetbucket}
            /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}
            /bin/mkdir -p /var/www/html/${asset_directory}
            /bin/chmod 777 /var/www/html/${asset_directory}
            /bin/chown www-data.www-data /var/www/html/${asset_directory}
            /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,sigv2 -o use_cache=${HOME}/datastore_cache -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi

if ( [ "${DATASTORE_PROVIDER}" = "linode" ] )
then
    export AWSACCESSKEYID=`/bin/cat ~/.s3cfg | /bin/grep '^access_key' | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/cat ~/.s3cfg | /bin/grep 'secret_key' | /usr/bin/awk '{print $NF}'`
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
            /usr/bin/s3cmd mb s3://${assetbucket}
            /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}
            /bin/mkdir -p /var/www/html/${asset_directory}
            /bin/chmod 777 /var/www/html/${asset_directory}
            /bin/chown www-data.www-data /var/www/html/${asset_directory}
            /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style -o use_cache=${HOME}/datastore_cache -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi

if ( [ "${DATASTORE_PROVIDER}" = "vultr" ] )
then
    export AWSACCESSKEYID=`/bin/cat ~/.s3cfg | /bin/grep '^access_key' | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/cat ~/.s3cfg | /bin/grep 'secret_key' | /usr/bin/awk '{print $NF}'`
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
            /usr/bin/s3cmd mb s3://${assetbucket}
            /usr/bin/s3cmd --preserve sync /var/www/html/${asset_directory}/* s3://${assetbucket}
            /bin/mkdir -p /var/www/html/${asset_directory}
            /bin/chmod 777 /var/www/html/${asset_directory}
            /bin/chown www-data.www-data /var/www/html/${asset_directory}
            /usr/bin/s3fs -o umask=0022 -o uid="${s3fs_uid}" -o gid="${s3fs_gid}" -o allow_other,nonempty,kernel_cache,use_path_request_style,sigv2 -o use_cache=${HOME}/datastore_cache -ourl=https://${endpoint} ${assetbucket} /var/www/html/${asset_directory}
        fi
        loop="`/usr/bin/expr ${loop} + 1`"
    done
    /bin/rm ${HOME}/runtime/SYNCINGASSETSTODATASTORE
fi
