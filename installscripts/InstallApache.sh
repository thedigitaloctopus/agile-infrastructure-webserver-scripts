
#!/bin/sh
######################################################################################################
# Description: This script will install the apache webserver
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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

if ( [ "${1}" != "" ] )
then
    BUILDOS="${1}"
fi

PHP_VERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'PHPVERSION'`"

if ( [ "${BUILDOS}" = "ubuntu" ] )
then

    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] )
    then
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        
         if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source:modsecurity'`" = "1" ] )
         then
             if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source:modsecurity:modevasive'`" = "1" ] )
             then
                 ${HOME}/installscripts/apache/BuildApacheFromSource.sh  Ubuntu modsecurity modevasive
             else
                 ${HOME}/installscripts/apache/BuildApacheFromSource.sh  Ubuntu modsecurity
             fi
         else
             ${HOME}/installscripts/apache/BuildApacheFromSource.sh  Ubuntu
         fi 
         
       # if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source:modsecurity:modevasive'`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source:modevasive'`" = "1" ] )
       # then
       #     /usr/bin/apt -qq -y install apache2-utils
       #     /usr/bin/apt -qq -y install libapache2-mod-evasive
       #     /usr/bin/ln -s /etc/apache2/mods-available/evasive.conf /etc/apache2/mods-enabled/evasive.conf
       #     /bin/sed -i 's/#//g' /etc/apache2/mods-available/evasive.conf
       #     notify_email_address="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SYSTEMTOEMAILADDRESS'`"
       #     /bin/sed -i "s/DOSEmailNotify.*/DOSEmailNotify ${notify_email_address}/g" /etc/apache2/mods-available/evasive.conf
       # fi
        
        /bin/touch /etc/apache2/BUILT_FROM_SOURCE
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:repo'`" = "1" ] )
    then
        /usr/bin/apt-get -qq -y install apache2
        if ( [  "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
        then
            /usr/bin/apt-get -qq -y install libapache2-mod-php${PHP_VERSION}
        fi
        
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:repo:modsecurity'`" = "1" ] )
        then
            /usr/bin/apt -y -qq install libapache2-mod-security2 
            /usr/sbin/a2enmod headers
            /bin/cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
            /bin/sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf

            /bin/rm -rf /usr/share/modsecurity-crs

            /usr/bin/git clone https://github.com/coreruleset/coreruleset /usr/share/modsecurity-crs
            /bin/mv /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
            /bin/mv /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf

            /bin/echo "<IfModule security2_module>
        SecDataDir /var/cache/modsecurity
        Include /usr/share/modsecurity-crs/crs-setup.conf
        Include /usr/share/modsecurity-crs/rules/*.conf
</IfModule>" > /etc/apache2/mods-available/security2.conf
        fi
        
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:repo:modsecurity:modevasive'`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:repo:modevasive'`" = "1" ] )
        then
             /usr/bin/apt -qq -y install apache2-utils
             /usr/bin/apt -qq -y install libapache2-mod-evasive
             /usr/bin/ln -s /etc/apache2/mods-available/evasive.conf /etc/apache2/mods-enabled/evasive.conf
             /bin/sed -i 's/#//g' /etc/apache2/mods-available/evasive.conf
             notify_email_address="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SYSTEMTOEMAILADDRESS'`"
             /bin/sed -i "s/DOSEmailNotify.*/DOSEmailNotify ${notify_email_address}/g" /etc/apache2/mods-available/evasive.conf
        fi
             
        /bin/touch /etc/apache2/BUILT_FROM_REPO
    fi
fi

if ( [ "${BUILDOS}" = "debian" ] )
then

    if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source'`" = "1" ] )
    then
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        
         if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source:modsecurity'`" = "1" ] )
         then
             if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source:modsecurity:modevasive'`" = "1" ] )
             then
                 ${HOME}/installscripts/apache/BuildApacheFromSource.sh  Ubuntu modsecurity modevasive
             else
                 ${HOME}/installscripts/apache/BuildApacheFromSource.sh  Ubuntu modsecurity
             fi
         else
             ${HOME}/installscripts/apache/BuildApacheFromSource.sh  Debian
         fi 
       #  if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source:modsecurity:modevasive'`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:source:modevasive'`" = "1" ] )
       #  then
       #      /usr/bin/apt -qq -y install apache2-utils
       #      /usr/bin/apt -qq -y install libapache2-mod-evasive
       #      /usr/bin/ln -s /etc/apache2/mods-available/evasive.conf /etc/apache2/mods-enabled/evasive.conf
       #      /bin/sed -i 's/#//g' /etc/apache2/mods-available/evasive.conf
       #      notify_email_address="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SYSTEMTOEMAILADDRESS'`"
       #      /bin/sed -i "s/DOSEmailNotify.*/DOSEmailNotify ${notify_email_address}/g" /etc/apache2/mods-available/evasive.conf
       #  fi
        /bin/touch /etc/apache2/BUILT_FROM_SOURCE
    elif ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:repo'`" = "1" ] )
    then
        /usr/bin/apt-get -qq -y install apache2
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATIONLANGUAGE:PHP`" = "1" ] )
        then
            /usr/bin/apt-get -qq -y install libapache2-mod-php${PHP_VERSION}
        fi
        
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:repo:modsecurity'`" = "1" ] )
        then
            /usr/bin/apt -y -qq install libapache2-mod-security2 
            /usr/sbin/a2enmod headers
            /bin/cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
            /bin/sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf

            /bin/rm -rf /usr/share/modsecurity-crs

            /usr/bin/git clone https://github.com/coreruleset/coreruleset /usr/share/modsecurity-crs
            /bin/mv /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
            /bin/mv /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf

            /bin/echo "<IfModule security2_module>
        SecDataDir /var/cache/modsecurity
        Include /usr/share/modsecurity-crs/crs-setup.conf
        Include /usr/share/modsecurity-crs/rules/*.conf
</IfModule>" > /etc/apache2/mods-available/security2.conf
        fi
        
        if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:repo:modsecurity:modevasive'`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'APACHE:repo:modevasive'`" = "1" ] )
        then
            /usr/bin/apt -qq -y install apache2-utils
            /usr/bin/apt -qq -y install libapache2-mod-evasive
            /usr/bin/ln -s /etc/apache2/mods-available/evasive.conf /etc/apache2/mods-enabled/evasive.conf
            /bin/sed -i 's/#//g' /etc/apache2/mods-available/evasive.conf
            notify_email_address="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SYSTEMTOEMAILADDRESS'`"
            /bin/sed -i "s/DOSEmailNotify.*/DOSEmailNotify ${notify_email_address}/g" /etc/apache2/mods-available/evasive.conf
        fi
        
        /bin/touch /etc/apache2/BUILT_FROM_REPO
    fi
fi

