cd /usr/local/src/httpd-2.4.43/srclib/
wget https://downloads.apache.org/apr/apr-1.7.0.tar.gz
tar -xzf apr-1.7.0.tar.gz
mv apr-1.7.0 apr


wget https://downloads.apache.org/apr/apr-util-1.6.1.tar.gz
tar -xzf apr-util-1.6.1.tar.gz
mv apr-util-1.6.1 apr-util

cd /usr/local/src/
wget https://downloads.apache.org//httpd/httpd-2.4.43.tar.gz
tar -xzf httpd-2.4.43.tar.gz
apt install build-essential libssl-dev libexpat-dev libpcre2-dev libapr1-dev libaprutil1-dev

cd /usr/local/src/httpd-2.4.43
./configure
make
make install
