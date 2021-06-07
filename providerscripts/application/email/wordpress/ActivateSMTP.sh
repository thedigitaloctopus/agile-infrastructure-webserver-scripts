#!/bin/sh
########################################################################################
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
#########################################################################################
#########################################################################################
#set -x

#To activate SMTP for wordpress, you need to  install and configure the WP Mail SMTP module through the GUI

#Your SMTP credentials are stored in /var/www/wordpresssmtp

/bin/echo "##################################################################"
/bin/echo "These are your SMTP credentials settings for your wordpress install"
/bin/echo "Please refer to: https://wordpress.org/plugins/wp-mail-smtp/"
/bin/echo "##################################################################"

fromaddress="`/bin/ls ${HOME}/.ssh/FROMADDRESS:* | /usr/bin/awk -F':' '{print $NF}'`"
username="`/bin/ls ${HOME}/.ssh/EMAILUSERNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
password="`/bin/ls ${HOME}/.ssh/EMAILPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
emailprovider="`/bin/ls ${HOME}/.ssh/EMAILPROVIDER:* | /usr/bin/awk -F':' '{print $NF}'`"

/bin/echo "FROM ADDRESS: ${fromaddress}" > /var/www/wordpresssmtp
/bin/echo "USERNAME: ${username}" >> /var/www/wordpresssmtp
/bin/echo "PASSWORD: ${password}" >> /var/www/wordpresssmtp
/bin/echo "EMAIL PROVIDER: ${emailprovider}" >> /var/www/wordpresssmtp
/bin/echo "PORT: 465" >> /var/www/wordpresssmtp

/bin/chmod 400 /var/www/wordpresssmtp
