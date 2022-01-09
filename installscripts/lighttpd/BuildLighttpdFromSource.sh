#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: This will install the lighttpd webserver from source
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
########################################################################################
########################################################################################
#set -x

/usr/bin/apt-get install  -o DPkg::Lock::Timeout=-1 -qq -y autoconf automake libtool m4 pkg-config 
/usr/bin/apt install  -o DPkg::Lock::Timeout=-1 -qq -y bzip2 libgeoip-dev gnutls-bin gnutls-dev libmaxminddb-dev libxml2 libmariadb-dev libpq-dev zlib1g-dev libssl-dev libpcre3-dev

release_series="1"
version_name="`/usr/bin/wget -O- - https://github.com/lighttpd | /bin/grep -o lighttpd[${release_series}].[0-9][0-9] | /bin/grep lighttpd | /usr/bin/head -1`"
if ( [ "${version_name}" = "" ] )
then
    version_name="`/usr/bin/wget -O- - https://github.com/lighttpd | /bin/grep -o lighttpd[${release_series}].[0-9] | /bin/grep lighttpd | /usr/bin/head -1`"
fi

/usr/bin/git clone https://github.com/lighttpd/${version_name}.git
cd ${version_name}
./autogen.sh
./configure -C --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib --with-geoip --with-gnutls --with-maxminddb --with-pgsql --with-mysql --with-openssl --with-pcre --with-rewrite --with-redirect --with-ssl
/usr/bin/make
/usr/bin/make install 

/bin/mkdir /etc/lighttpd
/bin/mkdir /var/log/lighttpd
/bin/chown www-data.www-data /var/log/lighttpd

/bin/cp ${HOME}/installscripts/lighttpd/lighttpd.conf.base /etc/lighttpd/lighttpd.conf
/bin/cp ./doc/config/modules.conf /etc/lighttpd/modules.conf
/bin/cp -r ./doc/config/conf.d /etc/lighttpd/

#Put code to start apache after a reboot
/bin/echo "#!/bin/bash
/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
/bin/sleep 10
lighties=\"\`/usr/bin/ps -ef | /bin/grep lighttp | /bin/grep -v grep | /usr/bin/wc -l\`\"
while ( [ \"\${lighties}\" = \"0\" ] )
do
    /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
    lighties=\"\`/usr/bin/ps -ef | /bin/grep lighttp | /bin/grep -v grep | /usr/bin/wc -l\`\"
    /bin/sleep 10
done
exit 0" > /etc/rc.local

/bin/chmod +x /etc/rc.local

/bin/echo "[Unit]
Description=/etc/rc.local Compatibility
Documentation=man:systemd-rc-local-generator(8)
ConditionFileIsExecutable=/etc/rc.local
After=network.target
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/rc-local.service
