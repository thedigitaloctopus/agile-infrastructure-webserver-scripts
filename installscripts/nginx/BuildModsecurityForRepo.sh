/usr/bin/apt-get -qq -y install bison build-essential ca-certificates curl dh-autoreconf doxygen flex gawk git iputils-ping libcurl4-gnutls-dev libexpat1-dev libgeoip-dev liblmdb-dev libpcre3-dev libpcre++-dev libssl-dev libtool libxml2 libxml2-dev libyajl-dev locales lua5.3-dev pkg-config wget zlib1g-dev zlibc libxslt libgd-dev

cd /opt

/usr/bin/git clone https://github.com/SpiderLabs/ModSecurity

cd ModSecurity

/usr/bin/git submodule init
/usr/bin/git submodule update

./build.sh

./configure

/usr/bin/make

/usr/bin/make install

cd /opt

/usr/bin/git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

${version}="`/usr/sbin/nginx -v 2>&1 >/dev/null | /usr/bin/awk -F'/' '{print $NF}' | /usr/bin/awk '{print $1}'`" 

/usr/bin/wget http://nginx.org/download/nginx-${version}.tar.gz

/usr/bin/tar -xvzmf nginx-${version}.tar.gz

cd nginx-${version}

configure_arguments="`/usr/sbin/nginx -V 2>&1 >/dev/null | /bin/grep "configure arguments:" | /bin/awk '{$1="";$2="";print $0}'`"

./configure --add-dynamic-module=../ModSecurity-nginx ${configure_arguments}

/usr/bin/make modules

/bin/mkdir /etc/nginx/modules

/bin/cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules

/bin/echo "load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;" > /etc/nginx/nginx.conf

/bin/rm -rf /usr/share/modsecurity-crs

/usr/bin/git clone https://github.com/coreruleset/coreruleset /usr/local/modsecurity-crs

/bin/mv /usr/local/modsecurity-crs/crs-setup.conf.example /usr/local/modsecurity-crs/crs-setup.conf

/bin/mv /usr/local/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/local/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf

/bin/mkdir -p /etc/nginx/modsec

/bin/cp /opt/ModSecurity/unicode.mapping /etc/nginx/modsec

/bin/cp /opt/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf

/bin/cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

/bin/sed -i 's/SecRuleEngine.*/SecRuleEngine On/g' /etc/modsecurity/modsecurity.conf

/bin/echo "Include /etc/nginx/modsec/modsecurity.conf
Include /usr/local/modsecurity-crs/crs-setup.conf
Include /usr/local/modsecurity-crs/rules/*.conf" > /etc/nginx/modsec/main.conf
