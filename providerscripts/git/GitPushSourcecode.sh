#!/bin/sh
#######################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : Commits sourcecode to the repository
#######################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

if ( [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ] || [ "$4" = "" ] )
then
    /bin/echo "Usage : ${0} : <files> <commit message> <repository provider> <repository name>"
    exit
fi

#If it's a manual backup, then these have to be set
if ( [ "$5" != "" ] && [ "$6" != "" ] && [ "$7" != "" ] && [ "$8" != "" ] )
then
    repository_provider=$5
    APPLICATION_REPOSITORY_USERNAME=$6
    APPLICATION_REPOSITORY_PASSWORD=$7
    APPLICATION_REPOSITORY_OWNER=$8
    APPLICATION_REPOSITORY_NAME="${4}"
else
    repository_provider="${3}"
    APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
    APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
    APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
    APPLICATION_REPOSITORY_NAME="${4}"
fi

if ( [ "${APPLICATION_REPOSITORY_USERNAME}" = "" ] || [ "${APPLICATION_REPOSITORY_PASSWORD}" = "" ] )
then
    /bin/echo "Please enter your repository username"
    read APPLICATION_REPOSITORY_USERNAME
    /bin/echo "Please enter your repository password"
    read APPLICATION_REPOSITORY_PASSWORD
fi

cd /tmp/backup

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh ".gitignore"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh .gitignore .
    /bin/echo "/tmp" >> /var/www/html/.gitignore
    /bin/echo "/logs" >> /var/www/html/.gitignore
fi

/bin/rm -r .git
/usr/bin/find /tmp/backup -type d -name .git -exec /bin/rm -rf {} \;
/usr/bin/git init
/usr/bin/git add ${1}

while ( [ "$?" != "0" ] )
do
    /usr/bin/git add ${1}
done

/usr/bin/git commit -m "${2}"

if ( [ "${repository_provider}" = "bitbucket" ] )
then
    /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@bitbucket.org/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
fi
if ( [ "${repository_provider}" = "github" ] )
then
    /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@github.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
fi
if ( [ "${repository_provider}" = "gitlab" ] )
then
    /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@gitlab.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
fi

/usr/bin/git push -f -u origin master

if ( [ ! -d /tmp/check ] )
then
    /bin/mkdir /tmp/check
fi 
/bin/rm -r /tmp/check/*

dir="`/usr/bin/pwd`"
cd /tmp/check

${HOME}/providerscripts/git/GitClone.sh ${repository_provider} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_REPOSITORY_NAME}

/usr/bin/diff -r /tmp/check/*/  /tmp/backup/ | /bin/grep -v '\.git' | grep "/tmp/check"  > /tmp/BackupDeltas.log
if ( [ "`/bin/cat /tmp/BackupDeltas.log`" != "" ] )
then
    /bin/echo "###########################################################################################" >> ${HOME}/logs/BackupDeltas.log
    /bin/echo "${APPLICATION_REPOSITORY_NAME} `/usr/bin/date`" >> ${HOME}/logs/BackupDeltas.log
    /bin/echo "###########################################################################################"
    /bin/cat /tmp/BackupDeltas.log >> ${HOME}/logs/BackupDeltas.log 
    ${HOME}/providerscripts/email/SendEmail.sh "POTENTIAL BACKUP INCONSISTENCY" "Check ${HOME}/logs/BackupDelta.log on machine: `${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

cd ${dir}
