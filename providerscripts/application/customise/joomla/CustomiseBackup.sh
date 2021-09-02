#!/bin/sh
###########################################################################################
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
##########################################################################################
##########################################################################################
#set -x
baseline_name="${1}"

/bin/cp ${HOME}/backups/${baseline_name}/configuration.php ${HOME}/backups/${baseline_name}/configuration.php.default
/usr/bin/unlink ${HOME}/backups/${baseline_name}/configuration.php
/bin/rm ${HOME}/backups/${baseline_name}/configuration.php
/bin/rm -r ${HOME}/backups/${baseline_name}/logs/*
/bin/rm -r ${HOME}/backups/${baseline_name}/tmp/*
/bin/sed -i "/\$host/c\        public \$host = \'xxxxxx\';" ${HOME}/backups/${baseline_name}/configuration.php.default
/bin/sed -i "/\$user/c\        public \$user = \'xxxxxx\';" ${HOME}/backups/${baseline_name}/configuration.php.default
/bin/sed -i "/\$password/c\        public \$password = \'xxxxxx\';" ${HOME}/backups/${baseline_name}/configuration.php.default
/bin/sed -i "/\$db /c\        public \$db = \'xxxxxx\';" ${HOME}/backups/${baseline_name}/configuration.php.default
/bin/sed -i "/\$secret /c\      public \$secret = \'xxxxxx\';" ${HOME}/backups/${baseline_name}/configuration.php.default



