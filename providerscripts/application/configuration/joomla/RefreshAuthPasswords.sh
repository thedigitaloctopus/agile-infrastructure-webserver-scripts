

if ( [ ! -f /etc/nginx/.htpasswd ] )
then
    /bin/touch /etc/nginx/.htpasswd
fi

#Update ConnectToRemoteDBMYSQLDB.sh with the "raw" output

user_table_name="`/bin/cat /var/www/html/dpb.dat`_users"
usernames="`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "select name from ${user_table_name}" raw`"
passwords="`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "select password from ${user_table_name}" raw`"

count="0"
for username in ${usernames}
do
    count="`/usr/bin/expr ${count} + 1`"
    password="`/bin/echo "${passwords}" | /usr/bin/cut -d " " -f ${count}`"
    matchablepassword="`/bin/echo ${password} | /bin/sed 's/$/\$/g'`"

    if ( [ "`/bin/cat /tmp/credentials | /bin/grep "${username}"`" = "" ] || [ "`/bin/cat /tmp/credentials | /bin/grep ${matchablepassword}`" = "" ] )
    then
        /bin/sed -i "/${username}/d" /etc/nginx/.htpasswd
        /bin/echo "${username}:${password}" >> /etc/nginx/.htpasswd
    fi
done
