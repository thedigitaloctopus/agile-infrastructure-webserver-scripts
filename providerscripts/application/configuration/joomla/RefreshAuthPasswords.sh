#set -x

if ( [ ! -f /etc/nginx/.htpasswd ] )
then
    /bin/touch /etc/nginx/.htpasswd
fi

user_table_name="`/bin/cat /var/www/html/dpb.dat`_users"
credentials="`${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "select name,password from ${user_table_name}" raw`"
credentials="${credentials} user1 password1"
usernames="`/bin/echo ${credentials} | /bin/tr ' ' '\n' | /bin/sed 'n; d'`"
passwords="`/bin/echo ${credentials} | /bin/tr ' ' '\n' | /bin/sed '1d; n; d'`"

credentials="`/bin/echo '${credentials}' | /bin/sed 's/\./\\./g' | /bin/sed 's/\[/\\[/g' | /bin/sed 's/\*/\\*/g' | /bin/sed 's;/;\\/;g' | /bin/sed 's/\$/\\\$/g' | /bin/sed 's/(/\\(/g' | /bin/sed 's/)/\\)/g'`"

echo $credentials

exit


for username in ${usernames}
do
   credentials="`/bin/echo ${credentials} | /bin/sed "s/${username} /${username}\:gap1\:/g"`"
done

for password in ${passwords}
do
   credentials="`/bin/echo ${credentials} | /bin/sed "s/${password} /${password}\|gap2|/g"`"
done

/bin/echo $credentials | /bin/sed 's/\:gap1\:/\:/g' | /bin/sed 's/|gap2|/\n/g' |  /bin/sed '/^$/d' > /etc/nginx/.htpasswd

exit

number_of_usernames="`/bin/echo ${usernames} | /usr/bin/wc -w`"

count="1"

while ( [ "${count}" -lt "${number_of_usernames}" ] )
do
    username="`/bin/echo "${usernames}" | cut -d " " -f ${count}`"
    password="`/bin/echo "${passwords}" | cut -d " " -f ${count}`"

    username="`/bin/echo "${usernames}" | awk 'print ${count}'`"
    password="`/bin/echo "${passwords}" | awk 'print ${count}'`"

    echo "$username $password"

    exit

    if ( [ "`/bin/cat /etc/nginx/.htpasswd | /bin/grep ${username}`" = "" ] &&  [ "`/bin/cat /etc/nginx/.htpasswd | /bin/grep ${password}`" = "" ] )
    then
        /bin/echo -n '${username}:${password}:' >> /etc/nginx/.htpasswd
    fi
    count="`/usr/bin/expr ${count} + 1`"
done
