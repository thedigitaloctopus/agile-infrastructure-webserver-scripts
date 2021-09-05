cd ${HOME}
if ( [ -d agile-infrastructure-webserver-scripts ] )
then
    /bin/rm -r agile-infrastructure-webserver-scripts
fi
infrastructure_repository_owner="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYOWNER'`"
/usr/bin/git clone https://github.com/${infrastructure_repository_owner}/agile-infrastructure-webserver-scripts.git
cd agile-infrastructure-webserver-scripts
/bin/cp -r * ${HOME}
cd ..
/bin/rm -r agile-infrastructure-webserver-scripts
