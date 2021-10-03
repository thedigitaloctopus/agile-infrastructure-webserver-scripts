#!/bin/sh
###########################################################################################################
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

domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"

/usr/bin/find . -type f -exec sed -i -e "s/${domainspecifier}/ApplicationDomainSpec/g" -e "s/${WEBSITE_URL}/applicationdomain.tld/g" -e "s/${ROOT_DOMAIN}/applicationrootdomain.tld/g" -e "s/${WEBSITE_DISPLAY_NAME}/The GreatApplication/g" -e "s/${WEBSITE_DISPLAY_NAME_UPPER}/THE GREATAPPLICATION/g" -e "s/${WEBSITE_DISPLAY_NAME}/GreatApplication/g" -e "s/${WEBSITE_DISPLAY_NAME_UPPER}/GREATAPPLICATION/g" -e "s/${WEBSITE_DISPLAY_NAME_LOWER}/greatapplication/g" -e "s/${WEBSITE_DISPLAY_NAME_FIRST}/Greatapplication/g" {} \;



