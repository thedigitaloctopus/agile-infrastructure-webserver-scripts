/usr/bin/apt-get install -qq -y autoconf automake libtool m4 pkg-config 
/usr/bin/apt install -qq -y bzip2 libgeoip-dev gnutls-bin libmaxminddb-dev libxml2 libmariadb-dev libpq-dev zlib1g-dev libssl-dev libpcre3-dev

/usr/bin/git clone https://github.com/lighttpd/lighttpd1.4.git
cd lighttp*
./autogen.sh
./configure -C --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib --with-geoip --with-gnutls --with-maxminddb --with-pgsql --with-mysql --with-openssl --with-pcre --with-rewrite --with-redirect --with-ssl
/usr/bin/make
/usr/bin/make install 

/bin/mkdir /etc/lighttpd

/bin/cp ./doc/config/lighttpd.conf /etc/lighttpd/lighttpd.conf
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
