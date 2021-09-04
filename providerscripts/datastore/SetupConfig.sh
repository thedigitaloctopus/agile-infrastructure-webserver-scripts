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

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PRODUCTION:1`" = "1" ] )
then
    if ( [ ! -d ${HOME}/config ] )
    then
        ${HOME}/providerscripts/utilities/SetupConfigDirectories.sh
    fi
    
    SSH_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SSHPORT'`"
    ALGORITHM="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'ALGORITHM'`"
    SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"
    ASIP="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'ASIP'`"
   # /usr/bin/scp -P ${SSH_PORT} -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -o ConnectTimeout=2 -o ConnectionAttempts=2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${SERVER_USER}@${ASIP}:${HOME}/config ${HOME}/config
    ASIPS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'ASIPS'`"

    for ip in ${ASIPS}
    do
        /bin/touch ${HOME}/config/autoscalerip/${ip}
        #if ( [ "${ASIP}" != "${ip}" ] )
        #then
        #    /usr/bin/scp -P ${SSH_PORT} -i ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY -o ConnectTimeout=2 -o ConnectionAttempts=2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${SERVER_USER}@${ip}:${HOME}/config ${HOME}/config
        #fi
    done
        
    #for publicautoscalerip in `/bin/ls ${HOME}/config/autoscalerpublicip`
    #do
    exit
fi

if ( [ "`/bin/ls ${HOME}/config 2>&1 | /bin/grep "Transport endpoint is not connected"`" != "" ] )
then
    /bin/umount -f ${HOME}/config
fi

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" != "" ] )
then
    if ( [ ! -d ${HOME}/config/beingbuiltips ] || [ ! -d ${HOME}/config/webserverpublicips ] || [ ! -d ${HOME}/config/webserverips ] || [ ! -d ${HOME}/config/databaseip ] || [ ! -d ${HOME}/config/databasepublicip ] || [ ! -d ${HOME}/config/bootedwebserverips ] || [ ! -d ${HOME}/config/shuttingdownwebserverips ] || [ ! -d ${HOME}/config/autoscalerip ] || [ ! -d ${HOME}/config/autoscalerpublicip ] || [ ! -d ${HOME}/config/buildclientip ] || [ ! -d ${HOME}/config/credentials ] || [ ! -d ${HOME}/config/cpuaggregator ] || [ ! -d ${HOME}/config/webrootsynctunnel ] || [ ! -d ${HOME}/config/ssl ] )
    then
        DIRECTORIESSET="0"
    else
        DIRECTORIESSET="1"
    fi

    if ( [ "${1}" = "forcepurge" ] )
    then
        /bin/rm -r ${HOME}/config/*
    fi

    if ( [ "${DIRECTORIESSET}" = "1" ] )
    then
        exit
    fi
fi

if ( [ ! -d ${HOME}/config_cache ] )
then
    /bin/mkdir -p ${HOME}/config_cache
fi

BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"

configbucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
configbucket="${configbucket}-config"
endpoint="`/bin/grep host_base ~/.s3cfg | /usr/bin/awk '{print $NF}'`"

if ( [ "${DATASTORE_CHOICE}" = "amazonS3" ] )
then
    export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
   
    if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
    then
       if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh ENABLEEFS:1`" = "1" ] )
       then
           aws_region="`/bin/grep region ${HOME}/.aws/config | /usr/bin/awk '{print $NF}'`"
           /bin/mkdir ~/.aws 2>/dev/null
           /bin/cp ${HOME}/.aws/* ~/.aws 2>/dev/null
           /bin/chmod 500 ~/.aws/*
           
           export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.aws/credentials | /usr/bin/awk '{print $NF}'`
           export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.aws/credentials | /usr/bin/awk '{print $NF}'`
           
           if ( [ ! -d ${HOME}/config ] )
           then
              /bin/mkdir ${HOME}/config
           fi

           /usr/bin/aws efs describe-file-systems | /usr/bin/jq '.FileSystems[] | .CreationToken + " " + .FileSystemId' | /bin/sed 's/\"//g' | while read identifier
           do
                if ( [ "`/bin/echo ${identifier} | /bin/grep ${configbucket}`" != "" ] )
                then
                    id="`/bin/echo ${identifier} | /usr/bin/awk '{print $NF}'`"
                    efsmounttarget="`/usr/bin/aws efs describe-mount-targets --file-system-id ${id} | /usr/bin/jq '.MountTargets[].IpAddress' | /bin/sed 's/"//g'`"
                    /bin/mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efsmounttarget}:/   ${HOME}/config
                 fi
            done
        else
            /usr/bin/s3cmd mb s3://${configbucket}
            /bin/rm -r ${HOME}/config_cache/* ${HOME}/config_cache/.* 2>/dev/null
            /usr/bin/s3fs -o nonempty,allow_other,kernel_cache,use_path_request_style,sigv2 -o use_cache=${HOME}/config_cache -ourl=https://${endpoint} ${configbucket} ${HOME}/config
        fi 
    fi
fi

if ( [ "${DATASTORE_CHOICE}" = "digitalocean" ] )
then
    export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    /usr/bin/s3cmd mb s3://${configbucket}
    if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
    then
        /bin/rm -r ${HOME}/config_cache/* ${HOME}/config_cache/.* 2>/dev/null
        /usr/bin/s3fs -o nonempty,allow_other,kernel_cache,use_path_request_style,sigv2 -o use_cache=${HOME}/config_cache -ourl=https://${endpoint} ${configbucket} ${HOME}/config
    fi
fi

if ( [ "${DATASTORE_CHOICE}" = "exoscale" ] )
then
    export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    /usr/bin/s3cmd mb s3://${configbucket}
    if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
    then
        /bin/rm -r ${HOME}/config_cache/* ${HOME}/config_cache/.* 2>/dev/null
        /usr/bin/s3fs -o nonempty,allow_other,kernel_cache,use_path_request_style,sigv2 -o use_cache=${HOME}/config_cache -ourl=https://${endpoint} ${configbucket} ${HOME}/config
    fi
fi

if ( [ "${DATASTORE_CHOICE}" = "linode" ] )
then
    export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    /usr/bin/s3cmd mb s3://${configbucket}
    if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
    then
        /bin/rm -r ${HOME}/config_cache/* ${HOME}/config_cache/.* 2>/dev/null
        /usr/bin/s3fs -o nonempty,allow_other,kernel_cache,use_path_request_style -o use_cache=${HOME}/config_cache -ourl=https://${endpoint} ${configbucket} ${HOME}/config
    fi
fi

if ( [ "${DATASTORE_CHOICE}" = "vultr" ] )
then
    export AWSACCESSKEYID=`/bin/grep '^access_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    export AWSSECRETACCESSKEY=`/bin/grep 'secret_key' ~/.s3cfg | /usr/bin/awk '{print $NF}'`
    /usr/bin/s3cmd mb s3://${configbucket}
    if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
    then
        /bin/rm -r ${HOME}/config_cache/* ${HOME}/config_cache/.* 2>/dev/null
        /usr/bin/s3fs -o nonempty,allow_other,kernel_cache,use_path_request_style,sigv2 -o use_cache=${HOME}/config_cache -ourl=https://${endpoint} ${configbucket} ${HOME}/config
    fi
fi

#if ( [ "$1" = "reboot" ] || [ -f ${HOME}/.ssh/AUTOSCALED ] )
#then
#    /bin/rm ${HOME}/config/*
 #   /bin/touch ${HOME}/config/INSTALLEDSUCCESSFULLY
#else
    # /bin/rm -r ${HOME}/config/*
#      :
  #  /bin/touch ${HOME}/config/INSTALLEDSUCCESSFULLY
#fi

/bin/touch ${HOME}/config/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK

${HOME}/providerscripts/utilities/SetupConfigDirectories.sh

