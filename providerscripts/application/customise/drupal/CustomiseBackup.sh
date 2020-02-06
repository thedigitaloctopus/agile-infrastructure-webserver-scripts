#!/bin/sh
##########################################################################################
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

salt="`/bin/cat ${HOME}/config/drupal_settings.php | /bin/grep '^\$settings' | /bin/grep 'hash_salt' | /usr/bin/head -1 | /usr/bin/awk -F'=' '{print $NF}' | /bin/sed "s/'//g" | /bin/sed 's/;//g' | /bin/sed 's/ //'`"
/bin/echo "${salt}" > /tmp/backup/salt
/usr/bin/unlink /tmp/backup/sites/default/settings.php
/bin/rm /tmp/backup/sites/default/settings.php

#Don't really know what I am doing here, but there was a problem with this file when building from a backup, so, I had to modify it inline
/bin/sed -i 's/!\$defaults/$defaults/' /var/www/html/core/modules/menu_ui/menu_ui.module
