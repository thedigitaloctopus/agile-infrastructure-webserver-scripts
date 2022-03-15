#!/bin/sh
##################################################################################
# Description: This scripts will configure the SMTP in the joomla configuration file
# for our selected SMTP provider
# Author: Peter Winter
# Date: 12/01/2017
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
##################################################################################
##################################################################################
#set -x

#Configure the details of the SMTP provider

website_display_name="${1}"
fromaddress="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SYSTEMFROMEMAILADDRESS'`"
username="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILUSERNAME'`"
password="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILPASSWORD'`"
emailprovider="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'EMAILPROVIDER'`"

while ( [ ! -f ${HOME}/runtime/APPLICATION_CONFIGURATION_PREPARED ] )
do
    /bin/sleep 30
done


if ( [ "${emailprovider}" = "1" ] )
then
    /bin/sed -i "/mailer/c\        public \$mailer = 'smtp';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/fromname/c\        public \$fromname = '""`/bin/echo ${website_display_name} | /bin/sed 's/_/ /g'`""';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/mailfrom/c\        public \$mailfrom = '"${fromaddress}"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpuser/c\        public \$smtpuser = '"${username}"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtppass/c\        public \$smtppass = '"${password}"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtphost/c\        public \$smtphost= '"smtp-pulse.com"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpport/c\        public \$smtpport= '"465"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpauth/c\        public \$smtpauth= '"1"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpsecure/c\        public \$smtpsecure= '"ssl"';" ${HOME}/runtime/joomla_configuration.php
fi
if ( [ "${emailprovider}" = "2" ] )
then
    /bin/sed -i "/mailer/c\        public \$mailer = 'smtp';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/fromname/c\        public \$fromname = '""`/bin/echo ${website_display_name} | /bin/sed 's/_/ /g'`""';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/mailfrom/c\        public \$mailfrom = '"${fromaddress}"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpuser/c\        public \$smtpuser = '"${username}"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtppass/c\        public \$smtppass = '"${password}"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtphost/c\        public \$smtphost= '"smtp.gmail.com"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpport/c\        public \$smtpport= '"465"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpauth/c\        public \$smtpauth= '"1"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpsecure/c\        public \$smtpsecure= '"ssl"';" ${HOME}/runtime/joomla_configuration.php
fi
if ( [ "${emailprovider}" = "3" ] )
then
    /bin/sed -i "/mailer/c\        public \$mailer = 'smtp';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/fromname/c\      public \$fromname = '""`/bin/echo ${website_display_name} | /bin/sed 's/_/ /g'`""';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/mailfrom/c\      public \$mailfrom = '"${fromaddress}"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpuser/c\      public \$smtpuser = '"${username}"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtppass/c\      public \$smtppass = '"${password}"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtphost/c\      public \$smtphost= '"email-smtp.eu-west-1.amazonaws.com"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpport/c\      public \$smtpport= '"465"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpauth/c\      public \$smtpauth= '"1"';" ${HOME}/runtime/joomla_configuration.php
    /bin/sed -i "/smtpsecure/c\    public \$smtpsecure= '"ssl"';" ${HOME}/runtime/joomla_configuration.php
fi
