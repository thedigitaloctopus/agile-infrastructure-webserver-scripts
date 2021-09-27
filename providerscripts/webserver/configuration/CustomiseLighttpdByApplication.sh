#!/bin/sh
##################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will customise the lighttpd configuration on an application
# by application basis. If you application has any specific settings it needs, then this
# is the place to put them.
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
#################################################################################
#################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then

    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
        /bin/echo "auth.backend = \"htpasswd\"
auth.backend.htpasswd.userfile= \"/etc/basicauth/.htpasswd\"
auth.require = ( \"/administrator\" => 
    (
    \"method\"  => \"basic\",
    \"realm\"   => \"Private Property\",
    \"require\" => \"valid-user\"
    ),
)" >> /etc/lighttpd/lighttpd.conf
    fi
    
    /bin/echo "
url.rewrite-final = (
\"^/$\" => \"/index.php\",
\"^/images.*\$\" => \"\$0\",
\"^/media.*\$\" => \"\$0\",
\"^/administrator.*\$\" => \"\$0\",
\"^/templates.*\$\" => \"\$0\",
\"^\/.+\.(php|css|js|png|gif|jpg|jpeg|ico|tif|bmp|exif|tiff|webp|swf|xml|pdf|doc|docx|txt|less|otf|eot|svg|svgz|ttf|woff|woff2).*\" => \"\$0\",
\"^/(.+)\" => \"/index.php/\$1\",
\"^/.*(\?.*)\" => \"/index.php\$1\"
    ) " >>  /etc/lighttpd/lighttpd.conf
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
        /bin/echo "auth.backend = \"htpasswd\"
auth.backend.htpasswd.userfile= \"/etc/basicauth/.htpasswd\"
auth.require = ( \"/wp-admin\" => 
    (
    \"method\"  => \"basic\",
    \"realm\"   => \"Private Property\",
    \"require\" => \"valid-user\"
    ),
)" >> /etc/lighttpd/lighttpd.conf
    fi
    
    /bin/echo "url.rewrite-once = (
\"^/(wp-.+).*/?\" => \"\$0\",
\"^/.*?(\?.*)?\$\" => \"/index.php\$1\"
)
    " >> /etc/lighttpd/lighttpd.conf
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
        /bin/echo "auth.backend = \"htpasswd\"
auth.backend.htpasswd.userfile= \"/etc/basicauth/.htpasswd\"
auth.require = ( \"/core\" => 
    (
    \"method\"  => \"basic\",
    \"realm\"   => \"Private Property\",
    \"require\" => \"valid-user\"
    ),
)" >> /etc/lighttpd/lighttpd.conf
    fi
    
    /bin/echo "
url.rewrite-final = (
  \"^/system/test/(.*)\$\" => \"/index.php?q=system/test/\$1\",
  \"^/([^.?]*)\?(.*)\$\" => \"/index.php?q=\$1&\$2\",
  \"^/([^.?]*)\$\" => \"/index.php?q=\$1\",
  \"^/rss.xml\" => \"/index.php?q=rss.xml\",
  \"^/(.+/files/styles/.+\.+.+)\?(.*)\$\" => \"/index.php?q=\$1&\$2\"
    ) " >> /etc/lighttpd/lighttpd.conf
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then
        /bin/echo "auth.backend = \"htpasswd\"
auth.backend.htpasswd.userfile= \"/etc/basicauth/.htpasswd\"
auth.require = ( \"/moodle/\" => 
    (
    \"method\"  => \"basic\",
    \"realm\"   => \"Private Property\",
    \"require\" => \"valid-user\"
    ),
)" >> /etc/lighttpd/lighttpd.conf
    fi
fi

/bin/echo "}" >>  /etc/lighttpd/lighttpd.conf










